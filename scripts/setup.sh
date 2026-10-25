#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
dry_run=false

if [[ ${1:-} == --dry-run && $# -eq 1 ]]; then
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

omarchy=false
if [[ -d /usr/share/omarchy ]]; then
  omarchy=true
  run bash "$repo_dir/scripts/packages/omarchy.sh"
fi

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

if $omarchy; then
  if ((${#pacman_packages[@]} + ${#yay_packages[@]})); then
    if $dry_run; then
      run omarchy pkg present "${pacman_packages[@]}" "${yay_packages[@]}"
    else
      omarchy pkg present "${pacman_packages[@]}" "${yay_packages[@]}" || {
        echo "Package verification failed; leaving unwanted packages installed." >&2
        exit 1
      }
    fi
  fi

  mapfile -t unwanted_packages < <(grep -Ev '^[[:space:]]*(#|$)' "$repo_dir/scripts/packages/unwanted.txt")
  installed_unwanted=()
  if $dry_run; then
    installed_unwanted=("${unwanted_packages[@]}")
  else
    for package in "${unwanted_packages[@]}"; do
      if pacman -Qq "$package" >/dev/null 2>&1; then
        installed_unwanted+=("$package")
      fi
    done
  fi
  if ((${#installed_unwanted[@]})); then
    run sudo pacman -R "${installed_unwanted[@]}"
  fi
fi

if $dry_run; then
  "$repo_dir/scripts/stow.sh" --dry-run
  run "$repo_dir/scripts/configs/install-bash-hook.sh"
else
  "$repo_dir/scripts/stow.sh"
  "$repo_dir/scripts/configs/install-bash-hook.sh"
fi

if $omarchy; then
  if $dry_run; then
    run "$repo_dir/scripts/configs/install-hyprland-hook.sh"
    echo '[dry-run] sudo ./overrides/omarchy/patch-nightlight.sh'
  else
    "$repo_dir/scripts/configs/install-hyprland-hook.sh"
    sudo "$repo_dir/overrides/omarchy/patch-nightlight.sh"
  fi

  display_plugin="$HOME/.config/omarchy/plugins/monitor-layout"
  if [[ ! -d $display_plugin ]]; then
    run omarchy plugin add https://github.com/kris-1/omarchy-monitor-layout.git --enable
  fi
fi

if $dry_run; then
  echo 'Dry run complete.'
else
  echo 'Setup complete.'
fi
