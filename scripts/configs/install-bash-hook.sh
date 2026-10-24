#!/usr/bin/env bash
set -e

file=$HOME/.bashrc
hook='[[ -f "$HOME/.config/bash/supplement.sh" ]]'

if [[ -L $file ]]; then
  echo "$file is a symlink; migrate it manually before installing the Bash hook." >&2
  exit 1
fi

if grep -Fq "$hook" "$file"; then
  echo "Bash supplement hook already installed."
  exit 0
fi

cat >>"$file" <<'EOF'

[[ -f "$HOME/.config/bash/supplement.sh" ]] &&
  source "$HOME/.config/bash/supplement.sh"
EOF
echo "Installed Bash supplement hook."
