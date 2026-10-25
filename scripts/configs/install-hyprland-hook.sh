#!/usr/bin/env bash
set -e

file=$HOME/.config/hypr/hyprland.lua
import='require("hyprland_overrides")'

[[ -f $file ]] || { echo "Missing $file; refusing to create it." >&2; exit 1; }

if grep -Fq "$import" "$file"; then
  echo "Hyprland supplement loader already installed."
  exit 0
fi

cat >>"$file" <<'EOF'

local supplement_path = os.getenv("HOME") .. "/.config/hypr/supplement/?.lua"
if not package.path:find(supplement_path, 1, true) then
  package.path = package.path .. ";" .. supplement_path
end
require("hyprland_overrides")
EOF
echo "Installed Hyprland supplement loader."
