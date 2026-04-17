#!/usr/bin/env bash
set -euo pipefail

workspace_dir="${WORKSPACE_DIR:?WORKSPACE_DIR is required}"
source_dir="${KERNEL_SOURCE_DIR:-/shared/src/tegu-kernel}"
manifest_url="${REPO_MANIFEST_URL:-$(git -C "${workspace_dir}" remote get-url origin)}"
manifest_branch="${REPO_MANIFEST_BRANCH:-halium-tegu}"
manifest_file="${REPO_MANIFEST_FILE:-default.xml}"
repo_depth="${REPO_DEPTH:-}"
sync_jobs="${REPO_SYNC_JOBS:-$(nproc)}"

repo_init_args=(
  -u "${manifest_url}"
  -b "${manifest_branch}"
  -m "${manifest_file}"
)

if [ -n "${repo_depth}" ]; then
  repo_init_args+=("--depth=${repo_depth}")
fi

mkdir -p "${source_dir}"
cd "${source_dir}"

if ! repo init "${repo_init_args[@]}"; then
  rm -rf .repo/manifests .repo/manifests.git
  repo init "${repo_init_args[@]}"
fi

repo sync \
  --current-branch \
  --force-sync \
  --no-clone-bundle \
  --no-tags \
  --optimized-fetch \
  --prune \
  -j"${sync_jobs}"
