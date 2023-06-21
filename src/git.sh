#!/usr/bin/env bash

########################################################
# Functions to operate git commands
########################################################

# clone the code repo this action is running in via the `gh` command line tool
git_checkout() {
  if ! gh repo clone "${GITHUB_REPOSITORY}" "${REPO_DIR}"; then
    print_red "failed to clone ${GITHUB_REPOSITORY}"
    return 1
  fi
  print_purple "##[debug] cloned ${GITHUB_REPOSITORY} to ${REPO_DIR}"
}

# Verify the tag in $GITHUB_REF_NAME and set $SIGNER to the given username if verification was successful
git_verify_tag() {
  local username=$1

  pushd "${REPO_DIR}" > /dev/null || return 1

  if git tag -v "${GITHUB_REF_NAME}" > /dev/null; then
    # shellcheck disable=SC2034 # SIGNER is declared in check.sh
    SIGNER=$username
    popd > /dev/null || return
    return
  fi

  popd > /dev/null || err "FAILED"
  return 1
}

