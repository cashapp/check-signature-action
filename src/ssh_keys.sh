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
    print_purple "##debug: ${ssh_dir} doesn't exist, creating dir"
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
  print_purple "##debug: ${username}'s email address: ${user_email}"

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
  print_purple "##debug: wrote $(wc -l < "$ALLOWED_SIGNERS_FILE" | tr -d \[:space:\]) SSH keys for ${username}"

  pushd "${repo_dir}" > /dev/null || return 1
  git config gpg.format ssh
  git config gpg.ssh.allowedSignersFile $ALLOWED_SIGNERS_FILE
  popd > /dev/null || return 1
  print_purple "##debug: configured git repo in ${repo_dir} to verify signatures using SSH keys stored in ${ALLOWED_SIGNERS_FILE}"
}
