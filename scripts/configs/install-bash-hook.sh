#!/usr/bin/env bash
set -euo pipefail

dry_run=false
[[ ${1:-} == --dry-run ]] && dry_run=true
[[ $# -le 1 ]] || { echo "Usage: $0 [--dry-run]" >&2; exit 2; }

rc_file=${BASHRC_FILE:-$HOME/.bashrc}
begin='# >>> supplement bash hook >>>'
end='# <<< supplement bash hook <<<'
hook='if [[ -f "$HOME/.config/bash/supplement.sh" ]]; then
  source "$HOME/.config/bash/supplement.sh"
fi'

if [[ ! -f $rc_file ]]; then
  printf 'Missing %s; refusing to create or replace an Omarchy-owned shell startup file.\n' "$rc_file" >&2
  exit 1
fi
begin_count=$(grep -Fxc "$begin" "$rc_file" || true)
end_count=$(grep -Fxc "$end" "$rc_file" || true)
if (( begin_count != end_count )) || (( begin_count > 1 )); then
  echo "Found incomplete or duplicate supplement hook markers in $rc_file; refusing to edit." >&2
  exit 1
fi
if (( begin_count == 1 )); then
  echo "Bash supplement hook already installed in $rc_file."
  exit 0
fi

printf 'Would append the marked supplement hook to %s.\n' "$rc_file"
if $dry_run; then exit 0; fi
{
  [[ ! -s $rc_file ]] || [[ $(tail -c1 "$rc_file" | wc -l) -eq 1 ]] || printf '\n'
  printf '\n%s\n%s\n%s\n' "$begin" "$hook" "$end"
} >>"$rc_file"
echo "Installed supplement hook in $rc_file."
