#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
dry_run=false

if [[ ${1:-} == --dry-run ]]; then
  dry_run=true
elif [[ $# -gt 0 ]]; then
  echo "Usage: $0 [--dry-run]" >&2
  exit 2
fi

run() {
  if $dry_run; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

[[ -r /etc/arch-release ]] || { echo "This setup targets Arch Linux." >&2; exit 1; }
command -v pacman >/dev/null || { echo "pacman is required." >&2; exit 1; }

if ! command -v stow >/dev/null; then
  run sudo pacman -S --needed stow
fi

mapfile -t pacman_packages < <(grep -Ev '^[[:space:]]*(#|$)' "$repo_dir/scripts/packages/pacman.txt")
if ((${#pacman_packages[@]})); then
  run sudo pacman -S --needed "${pacman_packages[@]}"
fi

mapfile -t yay_packages < <(grep -Ev '^[[:space:]]*(#|$)' "$repo_dir/scripts/packages/yay.txt")
if ((${#yay_packages[@]})); then
  command -v yay >/dev/null || { echo "Install yay to install the AUR selections." >&2; exit 1; }
  run yay -S --needed "${yay_packages[@]}"
fi

if $dry_run; then
  "$repo_dir/scripts/stow.sh" --dry-run
  run "$repo_dir/scripts/configs/install-bash-hook.sh"
else
  "$repo_dir/scripts/stow.sh"
  "$repo_dir/scripts/configs/install-bash-hook.sh"
fi

if [[ -d /usr/share/omarchy ]]; then
  if $dry_run; then
    echo '[dry-run] sudo ./overrides/omarchy/patch-nightlight.sh'
    run "$repo_dir/scripts/configs/install-hyprland-hook.sh"
  else
    sudo "$repo_dir/overrides/omarchy/patch-nightlight.sh"
    "$repo_dir/scripts/configs/install-hyprland-hook.sh"
  fi

  display_plugin="$HOME/.config/omarchy/plugins/monitor-layout"
  if [[ ! -d $display_plugin ]]; then
    run omarchy plugin add https://github.com/kris-1/omarchy-monitor-layout.git --enable
  fi
fi

echo 'Setup complete. Check the README for manual desktop and hardware steps.'
