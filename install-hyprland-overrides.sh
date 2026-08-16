#!/bin/bash
set -e

HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.lua"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERRIDES_DIR="$SCRIPT_DIR/overrides/hyprland"
OVERRIDES_FILE="$SCRIPT_DIR/overrides/hyprland/hyprland_overrides.lua"

PATH_LINE="package.path = package.path .. \";$OVERRIDES_DIR/?.lua\""
REQUIRE_LINE='require("hyprland_overrides")'

# Check if hyprland config exists
if [ ! -f "$HYPRLAND_CONFIG" ]; then
  echo "Hyprland config not found at $HYPRLAND_CONFIG"
  echo "Please install hyprland first"
  exit 1
fi

# Check if overrides config exists
if [ ! -f "$OVERRIDES_FILE" ]; then
  echo "Overrides config not found at $OVERRIDES_FILE"
  exit 1
fi

has_path_line=false
has_require_line=false

grep -Fxq "$PATH_LINE" "$HYPRLAND_CONFIG" && has_path_line=true
grep -Fxq "$REQUIRE_LINE" "$HYPRLAND_CONFIG" && has_require_line=true

if $has_path_line && $has_require_line; then
  echo "Both lines already present in $HYPRLAND_CONFIG, nothing to do"
elif $has_path_line && ! $has_require_line; then
  echo "Found package.path line but missing require line, inconsistent state, adding require line"
  echo "$REQUIRE_LINE" >>"$HYPRLAND_CONFIG"
elif ! $has_path_line && $has_require_line; then
  echo "Found require line but missing package.path line, inconsistent state, adding package.path line before it"
  # Insert the path line right before the require line so ordering stays correct
  awk -v pathline="$PATH_LINE" -v reqline="$REQUIRE_LINE" '
    $0 == reqline { print pathline }
    { print }
  ' "$HYPRLAND_CONFIG" >"$HYPRLAND_CONFIG.tmp" && mv "$HYPRLAND_CONFIG.tmp" "$HYPRLAND_CONFIG"
else
  echo "Adding package.path and require lines to $HYPRLAND_CONFIG"
  echo "" >>"$HYPRLAND_CONFIG"
  echo "$PATH_LINE" >>"$HYPRLAND_CONFIG"
  echo "$REQUIRE_LINE" >>"$HYPRLAND_CONFIG"
fi

echo "Hyprland overrides setup complete!"

echo "Reloading Hyprland..."
hyprctl reload || echo "Reload failed, check hyprctl configerrors"
