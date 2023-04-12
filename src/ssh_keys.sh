#!/usr/bin/env bash

########################################################
# Functions related to SSH key signing and verification
########################################################

ALLOWED_SIGNERS_FILE="/.ssh/allowed_signers"
readonly ALLOWED_SIGNERS_FILE

create_allowed_signers_file() {
  local username=$1
  local repo_dir=$2

  if [[ ! -d "${repo_dir}" ]]; then
    err "\"${repo_dir}\" doesn't exist, can't set SSH allowed public keys without a local git repo"
  fi

  local ssh_dir
  ssh_dir=$(dirname "${ALLOWED_SIGNERS_FILE}")

  if [[ ! -d "${ssh_dir}" ]]; then
    mkdir -p "${ssh_dir}"
  fi

  local user_email
  user_email=$(gh api \
    -H "${GH_HEADER_ACCEPT}" \
    -H "${GH_HEADER_API}" \
    /users/"${username}" | jq -r ".email")
  if [[ $user_email == "" ]]; then
    print_red "${username} doesn't have an email"
    return 1
  fi

  local keys
  keys=$(gh api \
    -H "$GH_HEADER_ACCEPT" \
    -H "$GH_HEADER_API" \
    /users/"${username}"/ssh_signing_keys | jq -r ".[].key")
  if [[ $keys == "" ]]; then
    print_yellow "no SSH keys found for $username ($user_email)"
    return 1
  fi

  if [[ -f "${ALLOWED_SIGNERS_FILE}" ]]; then
    rm "${ALLOWED_SIGNERS_FILE}"
  fi

  while IFS= read -r key
  do
    echo "${user_email} ${key}" >> $ALLOWED_SIGNERS_FILE
  done <<< "$keys"

  pushd "${repo_dir}" > /dev/null || return 1
  git config gpg.format ssh
  git config gpg.ssh.allowedSignersFile $ALLOWED_SIGNERS_FILE
  popd > /dev/null || return 1
}
