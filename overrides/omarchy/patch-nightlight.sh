#!/usr/bin/env bash
set -e

status=0
file=/usr/bin/omarchy-toggle-nightlight

if [[ ! -f $file ]]; then
  echo "Nightlight toggle not found: $file" >&2
  status=1
elif grep -q '^ON_TEMP=4000$' "$file"; then
  sed -i 's/^ON_TEMP=4000$/ON_TEMP=1000/' "$file"
  echo "Set nightlight toggle temperature to 1000K."
elif grep -q '^ON_TEMP=1000$' "$file"; then
  echo "Nightlight toggle already set to 1000K."
else
  echo "Unexpected nightlight toggle setting in $file; left unchanged." >&2
  status=1
fi

file=/usr/share/omarchy/shell/plugins/services/nightlight/Service.qml

if [[ ! -f $file ]]; then
  echo "Nightlight service not found: $file" >&2
  status=1
elif grep -q '^  readonly property int nightTemperature: 4000$' "$file"; then
  sed -i 's/^  readonly property int nightTemperature: 4000$/  readonly property int nightTemperature: 1000/' "$file"
  echo "Set nightlight bar temperature to 1000K. Reload the shell to apply it."
elif grep -q '^  readonly property int nightTemperature: 1000$' "$file"; then
  echo "Nightlight bar already set to 1000K."
else
  echo "Unexpected nightlight service setting in $file; left unchanged." >&2
  status=1
fi

exit "$status"
