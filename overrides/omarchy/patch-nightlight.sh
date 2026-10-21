#!/usr/bin/env bash
set -euo pipefail

target=${NIGHTLIGHT_TARGET:-/usr/bin/omarchy-toggle-nightlight}
dry_run=false
[[ ${1:-} == --dry-run ]] && dry_run=true
[[ $# -le 1 ]] || { echo "Usage: $0 [--dry-run]" >&2; exit 2; }
[[ -f $target ]] || { echo "Nightlight target not found: $target" >&2; exit 1; }

mapfile -t assignments < <(grep -E '^[[:space:]]*ON_TEMP=' "$target" || true)
if ((${#assignments[@]} != 1)); then
  echo "Expected exactly one ON_TEMP assignment in $target; found ${#assignments[@]}." >&2
  exit 1
fi
line=${assignments[0]}
if [[ $line =~ ^[[:space:]]*ON_TEMP=1000[[:space:]]*$ ]]; then
  echo "Nightlight override already applied in $target."
  exit 0
elif [[ ! $line =~ ^[[:space:]]*ON_TEMP=4000[[:space:]]*$ ]]; then
  echo "Unexpected ON_TEMP assignment in $target; refusing to patch: $line" >&2
  exit 1
fi

echo "Would change only ON_TEMP=4000 to ON_TEMP=1000 in $target."
$dry_run && exit 0
tmp=$(mktemp "${target}.supplement.XXXXXX")
trap 'rm -f -- "$tmp"' EXIT
cp -p -- "$target" "$tmp"
awk '{ if ($0 ~ /^[[:space:]]*ON_TEMP=4000$/) sub(/ON_TEMP=4000$/, "ON_TEMP=1000"); print }' "$target" >"$tmp"
chown --reference="$target" "$tmp"
chmod --reference="$target" "$tmp"
mv -- "$tmp" "$target"
trap - EXIT
echo "Applied nightlight temperature override in $target."
