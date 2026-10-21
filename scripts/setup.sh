#!/usr/bin/env bash
set -uo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
dry_run=false
skip_packages=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=true ;;
    --skip-packages) skip_packages=true ;;
    -h|--help)
      cat <<'EOF'
Usage: ./scripts/setup.sh [--dry-run] [--skip-packages]

Installs the curated Arch package manifests, deploys Stow packages, and applies
Omarchy-specific overrides. User services are inspected but never enabled.
Package removals and mise runtime installations/upgrades are never automatic.
EOF
      exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

failed=0
step() { printf '\n==> %s\n' "$*"; }
run() {
  if $dry_run; then printf '[dry-run]'; printf ' %q' "$@"; printf '\n'; return 0; fi
  "$@" || { printf 'FAILED: %s\n' "$*" >&2; failed=1; return 0; }
}

step 'Check platform and required commands'
if [[ ! -r /etc/arch-release ]]; then
  echo 'This bootstrap currently supports Arch Linux only.' >&2
  exit 1
fi
for command_name in pacman stow; do
  if ! command -v "$command_name" >/dev/null; then echo "Missing prerequisite: $command_name" >&2; failed=1; fi
done
if (( failed )); then exit 1; fi

if ! $skip_packages; then
  step 'Install selected pacman packages'
  mapfile -t pacman_packages < <(grep -Ev '^[[:space:]]*(#|$)' "$repo_dir/scripts/packages/pacman.txt")
  if ((${#pacman_packages[@]})); then run sudo pacman -S --needed "${pacman_packages[@]}"; fi

  step 'Install selected yay packages'
  if ! command -v yay >/dev/null; then
    echo 'yay is unavailable; skipping AUR packages. Install yay manually, then rerun.' >&2
    failed=1
  else
    mapfile -t yay_packages < <(grep -Ev '^[[:space:]]*(#|$)' "$repo_dir/scripts/packages/yay.txt")
    if ((${#yay_packages[@]})); then run yay -S --needed "${yay_packages[@]}"; fi
  fi
else
  step 'Package installation skipped by request'
fi

step 'Deploy portable configuration with GNU Stow'
if $dry_run; then "$repo_dir/scripts/stow.sh" --dry-run || failed=1; else run "$repo_dir/scripts/stow.sh"; fi

step 'Install the marked interactive Bash hook'
if $dry_run; then "$repo_dir/scripts/configs/install-bash-hook.sh" --dry-run || failed=1; else run "$repo_dir/scripts/configs/install-bash-hook.sh"; fi

if [[ -d /usr/share/omarchy ]]; then
  step 'Preview/apply Omarchy-specific patches'
  if $dry_run; then
    "$repo_dir/overrides/omarchy/patch-nightlight.sh" --dry-run || failed=1
    python3 "$repo_dir/overrides/omarchy/patch-skill-metadata.py" --dry-run || failed=1
  else
    run sudo "$repo_dir/overrides/omarchy/patch-nightlight.sh"
    run sudo python3 "$repo_dir/overrides/omarchy/patch-skill-metadata.py"
  fi
else
  step 'Omarchy overrides skipped (Omarchy not detected)'
fi

step 'External tools, services, and verification'
echo 'mise config is deployed; runtime installation/upgrades are intentionally left explicit.'
echo 'No user services were enabled, restarted, or modified.'
echo 'Manual follow-up: sign in to Toolbox and install IDEs; configure local OpenCode credentials.'
if (( failed )); then echo 'Setup completed with one or more failures; review messages above.' >&2; exit 1; fi
echo 'Setup completed.'
