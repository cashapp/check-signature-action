#!/usr/bin/env bash

set -uo pipefail

# Foreground color coding
_RST="\033[0m" # resets color and format
readonly _RST
_RED="\033[0;31m"
readonly _RED
_GREEN="\033[0;32m"
readonly _GREEN
_BLUE="\033[0;34m"
readonly _BLUE
_YELLOW="\033[0;33m"
readonly _YELLO
_PURPLE="\033[0;35m"
readonly _PURPLE

# GitHub CLI common HTTP headers

# shellcheck disable=SC2034 # Variables used in other script files
GH_HEADER_ACCEPT="Accept: application/vnd.github+json"
# shellcheck disable=SC2034
readonly GH_HEADER_ACCEPT

# shellcheck disable=SC2034
GH_HEADER_API="X-GitHub-Api-Version: 2022-11-28"
# shellcheck disable=SC2034
readonly GH_HEADER_API


#######################################################
# Helper functions
#######################################################

err() {
  echo -e "${_RED}$*${_RST}" >&2
  exit 1
}

warn() {
  echo -e "${_YELLOW}$*${_RST}" >&2
}

print_red() {
  echo -e "${_RED}$*${_RST}"
}

print_green() {
  echo -e "${_GREEN}$*${_RST}"
}

print_blue() {
  echo -e "${_BLUE}$*${_RST}"
}

print_yellow() {
  echo -e "${_YELLOW}$*${_RST}"
}

print_purple() {
  echo -e "${_PURPLE}$*${_RST}"
}

get_authorized_usernames() {
  pushd "${REPO_DIR}" > /dev/null || return 1

  print_purple "##[debug] step ID: \"${GITHUB_ACTION}\""
  print_purple "##[debug] extracting list of authorized usernames from ${WORKFLOW_FILE_PATH}"

  # shellcheck disable=SC2034
  USERNAMES=$(yq e ".jobs.${GITHUB_JOB}.steps.[] | select(.id == \"${GITHUB_ACTION}\") | .with.allowed-release-signers" "${WORKFLOW_FILE_PATH}")
  if [[ $USERNAMES == "" ]]; then
    print_red "Failed to get a list of allowed usernames"
    return 1
  fi

  popd > /dev/null || return 1

  print_purple "##[debug] allowed usernames for release: \"${USERNAMES}\""
}
