#!/usr/bin/env bash
set -euo pipefail

source_dir="${KERNEL_SOURCE_DIR:-/shared/src/husky-kernel}"
patches_dir="${source_dir}/kernel-patches"
dist_dir="${source_dir}/out/shusky/dist"

cd "${source_dir}"

if [ -d "${patches_dir}" ]; then
  while IFS= read -r repo_dir; do
    [ -z "${repo_dir}" ] && continue
    if [ -d "${repo_dir}/.git" ] || [ -L "${repo_dir}/.git" ]; then
      git -C "${repo_dir}" reset --hard HEAD
      git -C "${repo_dir}" clean -fd
    fi
  done < <(find "${patches_dir}" -name '*.patch' -printf '%P\n' | xargs -r -n1 dirname | sort -u)

  "${patches_dir}/apply-patches.sh"
fi

if [ ! -f ./build_shusky.sh ]; then
  echo "build_shusky.sh was not found in ${source_dir}" >&2
  exit 1
fi

tools/bazel run --//build/kernel/kleaf:lto=none --config=stamp --config=shusky //private/devices/google/shusky:zuma_shusky_dist

if [ ! -d "${dist_dir}" ]; then
  echo "Expected output directory not found: ${dist_dir}" >&2
  exit 1
fi

find "${dist_dir}" -maxdepth 1 -type f -name '*.img' | sort
