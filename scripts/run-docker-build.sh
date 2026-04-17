#!/usr/bin/env bash
set -euo pipefail

workspace_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
image_tag="${IMAGE_TAG:-lineage-kernel-tegu-builder:local}"
source_dir="${KERNEL_SOURCE_DIR:-/shared/src/tegu-kernel}"
ssh_host="${REPO_HOST:-git.deusch.me}"
ssh_port="${REPO_SSH_PORT:-222}"
ssh_key="${SSH_KEY:-}"
skip_docker_build="${SKIP_DOCKER_BUILD:-0}"
container_home="/tmp/kernel-home"
container_ssh_dir="${container_home}/.ssh"

mkdir -p /shared "${source_dir}"

if [ "${skip_docker_build}" != "1" ]; then
  docker build -t "${image_tag}" -f "${workspace_dir}/Dockerfile" "${workspace_dir}"
fi

ssh_dir="$(mktemp -d "${workspace_dir}/.ci-ssh.XXXXXX")"
trap 'rm -rf "${ssh_dir}"' EXIT

chmod 700 "${ssh_dir}"

if [ -n "${ssh_key}" ]; then
  printf '%s\n' "${ssh_key}" > "${ssh_dir}/id_ed25519"
  chmod 600 "${ssh_dir}/id_ed25519"
elif [ -d "${HOME}/.ssh" ]; then
  cp -a "${HOME}/.ssh/." "${ssh_dir}/"
fi

touch "${ssh_dir}/known_hosts"
chmod 600 "${ssh_dir}/known_hosts"
ssh-keyscan -H -p "${ssh_port}" -4 "${ssh_host}" >> "${ssh_dir}/known_hosts"

ssh_command="ssh -p ${ssh_port} -o UserKnownHostsFile=${container_ssh_dir}/known_hosts -o StrictHostKeyChecking=yes"
if [ -n "${ssh_key}" ]; then
  ssh_command="${ssh_command} -i ${container_ssh_dir}/id_ed25519 -o IdentitiesOnly=yes"
fi

docker run --rm \
  --user "$(id -u):$(id -g)" \
  -e HOME="${container_home}" \
  -e WORKSPACE_DIR="$(pwd)" \
  -e KERNEL_SOURCE_DIR="${source_dir}" \
  -e REPO_MANIFEST_URL="${REPO_MANIFEST_URL:-$(git -C "${workspace_dir}" remote get-url origin)}" \
  -e REPO_MANIFEST_BRANCH="${REPO_MANIFEST_BRANCH:-$(git -C "${workspace_dir}" branch --show-current || printf '%s' halium-tegu)}" \
  -e REPO_MANIFEST_FILE="${REPO_MANIFEST_FILE:-default.xml}" \
  -e REPO_SYNC_JOBS="${REPO_SYNC_JOBS:-}" \
  -e BUILD_JOBS="${BUILD_JOBS:-}" \
  -e REPO_HOST="${ssh_host}" \
  -e REPO_SSH_PORT="${ssh_port}" \
  -e SSH_DIR_IN_CONTAINER="${ssh_dir}" \
  -e GIT_SSH_COMMAND="${ssh_command}" \
  --volumes-from "${JOB_CONTAINER_NAME}" \
  -w "$(pwd)" \
  -v /etc/group:/etc/group:ro \
  -v /etc/passwd:/etc/passwd:ro \
  -v /shared:/shared \
  "${image_tag}" \
  ./scripts/run-in-container.sh
