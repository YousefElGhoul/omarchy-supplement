#!/usr/bin/env bash
set -e

file=/usr/bin/omarchy-toggle-nightlight

if grep -q '^ON_TEMP=4000$' "$file"; then
  sed -i 's/^ON_TEMP=4000$/ON_TEMP=1000/' "$file"
  echo "Set nightlight temperature to 1000K."
else
  echo "Nightlight setting already changed."
fi
