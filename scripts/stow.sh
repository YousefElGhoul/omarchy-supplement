#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
packages_dir=$repo_dir/dotfiles
dry_run=false
if [[ ${1:-} == --dry-run ]]; then dry_run=true; shift; fi
[[ $# -eq 0 ]] || { echo "Usage: $0 [--dry-run]" >&2; exit 2; }
command -v stow >/dev/null || { echo "GNU Stow is required." >&2; exit 1; }

mapfile -t packages < <(
  find "$packages_dir" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | while IFS= read -r package; do
    if find "$packages_dir/$package" \( -type f -o -type l \) -print -quit | grep -q .; then
      printf '%s\n' "$package"
    fi
  done
)
((${#packages[@]})) || { echo "No Stow packages found in $packages_dir."; exit 0; }

echo "Stow target: $HOME"
echo "Packages: ${packages[*]}"
echo "Credential paths ending in server.env or github-pat.env are excluded."
stow_args=(-d "$packages_dir" -t "$HOME" --no-folding --ignore='(^|/)(server|github-pat)\.env$' --verbose)
$dry_run && stow_args+=(--simulate)
failed=0
for package in "${packages[@]}"; do
  echo "Deploying Stow package: $package"
  if ! stow "${stow_args[@]}" "$package"; then
    echo "Package $package was not fully deployed; resolve its reported conflicts and retry." >&2
    failed=1
  fi
done
exit "$failed"
