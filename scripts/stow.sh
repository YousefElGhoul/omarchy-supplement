#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
dry_run=false
[[ ${1:-} == --dry-run ]] && dry_run=true
[[ $# -le 1 ]] || { echo "Usage: $0 [--dry-run]" >&2; exit 2; }

packages=()
for path in "$repo_dir"/dotfiles/*; do
  [[ -d $path ]] || continue
  package=${path##*/}
  [[ $package == bashrc ]] && continue
  [[ -n $(find "$path" -type f -print -quit) ]] || continue
  packages+=("$package")
done

((${#packages[@]})) || { echo "No Stow packages found."; exit 0; }
if ! command -v stow >/dev/null; then
  if $dry_run; then
    echo "GNU Stow is not installed; setup will install it before deployment."
    exit 0
  fi
  echo "GNU Stow is required; run ./scripts/setup.sh first." >&2
  exit 1
fi
args=(-d "$repo_dir/dotfiles" -t "$HOME" --no-folding --ignore='(^|/)(server|github-pat)\.env$')
$dry_run && args+=(--simulate)
stow "${args[@]}" "${packages[@]}"
