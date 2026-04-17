#!/usr/bin/env bash
set -euo pipefail

source_dir="${KERNEL_SOURCE_DIR:-/shared/src/tegu-kernel}"
dist_dir="${source_dir}/out/tegu/dist"

cd "${source_dir}"

if [ ! -f ./build_tegu.sh ]; then
  echo "build_tegu.sh was not found in ${source_dir}" >&2
  exit 1
fi

bash ./build_tegu.sh

if [ ! -d "${dist_dir}" ]; then
  echo "Expected output directory not found: ${dist_dir}" >&2
  exit 1
fi

find "${dist_dir}" -maxdepth 1 -type f -name '*.img' | sort
