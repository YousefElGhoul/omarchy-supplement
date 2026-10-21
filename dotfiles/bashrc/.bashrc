# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
# /etc/omarchy.conf is written by omarchy-dev-link. When absent, force the
# package default instead of preserving a stale inherited dev-link value before
# we decide which rc file to source.

if [[ -f /etc/omarchy.conf ]]; then
  source /etc/omarchy.conf
  export OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
else
  export OMARCHY_PATH=/usr/share/omarchy
fi
source "$OMARCHY_PATH/default/bash/rc"

export PATH=$HOME/.local/bin:$PATH

# Load Angular CLI autocompletion.
# source <(ng completion script)

alias code='codium'

alias dev='tmuxp load laptop-dev'
alias ddev='tmuxp load laptop-docker-dev'
alias adev='tmuxp load laptop-ai-dev'
alias dadev='tmuxp load laptop-ai-docker-dev'

alias tdev='tmuxp load tablet-dev'
alias tddev='tmuxp load tablet-docker-dev'
alias tadev='tmuxp load tablet-ai-dev'
alias tdadev='tmuxp load tablet-ai-docker-dev'

alias edit='NVIM_APPNAME=nvim-ghoul nvim'
alias mdedit='NVIM_APPNAME=nvim-markdown nvim'

alias editrc='nvim ~/.bashrc'
alias rsource='source ~/.bashrc'

# OpenCode TUI connects to the persistent local server
opencode() {
  case "${1:-}" in
  serve | upgrade | auth | session | api | models | mcp | debug | --version | -v | --help | -h)
    command opencode "$@"
    ;;
  *)
    (
      source "$HOME/.config/opencode/server.env"
      export OPENCODE_PASSWORD
      command opencode --server http://127.0.0.1:4096 "$@"
    )
    ;;
  esac
}
