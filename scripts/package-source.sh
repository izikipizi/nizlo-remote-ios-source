#!/bin/bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $0 source.tar.gz [build-commit]" >&2
  exit 2
fi

output=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
root_dir=$(cd "$(dirname "$0")/.." && pwd)
ref=${2:-HEAD}
submodule_commit=$(git -C "$root_dir" rev-parse "$ref:libs/hbb_common")
test ! -e "$output"
work=$(mktemp -d /private/tmp/nizlo-remote-source.XXXXXX)
trap 'rm -rf "$work"' EXIT

git -C "$root_dir" archive "$ref" | tar -xf - -C "$work"
mkdir -p "$work/libs/hbb_common"
git -C "$root_dir/libs/hbb_common" archive "$submodule_commit" | tar -xf - -C "$work/libs/hbb_common"
test -f "$work/LICENCE"
test -f "$work/libs/hbb_common/Cargo.toml"
tar -czf "$output" -C "$work" .
shasum -a 256 "$output" > "$output.sha256"
echo "Corresponding source: $output"
