#!/usr/bin/env bash
set -euo pipefail

workspace_dir="${WORKSPACE_DIR:?WORKSPACE_DIR is required}"
home_dir="${HOME:-/tmp/kernel-home}"
source_dir="${KERNEL_SOURCE_DIR:-/shared/src/husky-kernel}"
ssh_dir_in_container="${SSH_DIR_IN_CONTAINER:-${home_dir}/.ssh}"
debug_ssh="${DEBUG_SSH:-0}"
git_user_name="${GIT_USER_NAME:-Forgejo CI}"
git_user_email="${GIT_USER_EMAIL:-ci@git.deusch.me}"

mkdir -p "${home_dir}"
rm -rf "${home_dir}/.ssh"
ln -s "${ssh_dir_in_container}" "${home_dir}/.ssh"

if [ -n "${GIT_SSH_COMMAND:-}" ]; then
  git config --global core.sshCommand "${GIT_SSH_COMMAND}"
fi

git config --global user.name "${git_user_name}"
git config --global user.email "${git_user_email}"
git config --global --add safe.directory "${workspace_dir}"
git config --global --add safe.directory "${source_dir}"

if [ "${debug_ssh}" = "1" ]; then
  echo "=== SSH debug start ==="
  echo "HOME=${HOME}"
  echo "whoami=$(id -un)"
  echo "uidgid=$(id -u):$(id -g)"
  echo "core.sshCommand=$(git config --global --get core.sshCommand || true)"
  echo "ssh_dir_in_container=${ssh_dir_in_container}"
  ls -la "${ssh_dir_in_container}"
  ssh -V || true
  set +e
  sh -c "${GIT_SSH_COMMAND:-ssh} -vvv -T git@git.deusch.me" < /dev/null
  set -e
  echo "=== SSH debug end ==="
fi

"${workspace_dir}/scripts/bootstrap-tree.sh"
"${workspace_dir}/scripts/build-kernel.sh"
