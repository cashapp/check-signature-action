#!/usr/bin/env bash

SCRIPT_SOURCE=$(dirname "${BASH_SOURCE[0]}")

# shellcheck source=src/utils.sh
source "${SCRIPT_SOURCE}"/utils.sh
# shellcheck source=src/git.sh
source "${SCRIPT_SOURCE}"/git.sh
# shellcheck source=src/ssh_keys.sh
source "${SCRIPT_SOURCE}"/ssh_keys.sh

USERNAMES=""
SIGNER=""

workflow_file_path_with_ref="${GITHUB_WORKFLOW_REF#"$GITHUB_REPOSITORY"/*}"
WORKFLOW_FILE_PATH="${workflow_file_path_with_ref%@*}"
readonly WORKFLOW_FILE_PATH

if [[ $GITHUB_ACTION == "__cashapp_check-signature-action" ]]; then
  print_red "cashapp/check-signature-action is missing an 'id' value in the ${WORKFLOW_FILE_PATH} yaml file"
  print_red "Please add an explicit and unique id in the workflow YAML file for this step"
  return 1
fi
print_purple "##[debug] step ID: ${GITHUB_ACTION}"

if [[ $GITHUB_REF_TYPE != "tag" ]]; then
  err "Signature check is only supported for git tags"
fi

REPO_NAME=$(echo "${GITHUB_REPOSITORY}" | cut -d'/' -f2)
readonly REPO_NAME

if ! git_checkout; then
  err "FAILED"
fi

if ! get_authorized_usernames; then
  err "FAILED"
fi

for username in $(echo "${USERNAMES}" | tr "," "\n"); do
  print_blue "Verifying tag $GITHUB_REF_NAME with $username's keys"
  if ! create_allowed_signers_file "${username}" "${REPO_NAME}"; then
    continue
  fi

  if git_verify_tag "${username}"; then
    print_green "$GITHUB_REF_NAME was signed by $SIGNER"
    echo "signed_by=$SIGNER" >> "$GITHUB_OUTPUT"
    break
  fi
done

if [[ "${SIGNER}" == "" ]]; then
  err "FAILED: no authorized user signed tag \"${GITHUB_REF_NAME}\""
fi
