# Supplement

Personal Arch/Omarchy setup: install selected apps, Stow personal configs, add
small Bash/Hyprland hooks, and set Omarchy's nightlight toggle to 1000K.

## Setup

On a fresh Omarchy install:

```bash
./scripts/setup.sh --dry-run
./scripts/setup.sh
```

Setup installs GNU Stow first if needed, then the curated pacman/yay lists,
deploys `dotfiles/`, installs the shell/Hyprland hooks, applies the nightlight
change, and installs the third-party display widget if absent. It never removes
packages, enables services, or installs mise runtimes. Do not use `--adopt`.

GNU Stow reports conflicting files itself. On a fresh install, back up any
Omarchy-created file that conflicts with a personal Stow file (notably
`~/.config/omarchy/shell.json`), then rerun setup. Existing machine-local config
is not overwritten automatically.

## What is managed

- `dotfiles/`: Bash supplement, Hyprland Lua, mise, OpenCode, tmux/tmuxp,
  user services, Omarchy bar settings/plugins, selected terminal settings,
  WirePlumber rules, and KeePassXC autostart.
- `overrides/omarchy/patch-nightlight.sh`: changes only
  `/usr/bin/omarchy-toggle-nightlight` from `ON_TEMP=4000` to `1000`. Rerun
  `sudo ./overrides/omarchy/patch-nightlight.sh` after an Omarchy update if it
  resets. No pacman hook is installed.
- `scripts/packages/`: selected applications beyond Omarchy defaults. The
  manifest omits Omarchy-provided tools such as Neovim and lazydocker. Zen
  Browser and Voxtype use the configured Omarchy pacman repository; Toolbox is
  the only current AUR selection. `github-cli` is omitted because mise manages
  `gh` already.

The personal bar setup preserves `ghoul.indicators`, its keyboard/webcam helper
scripts, and the modified `ghoul.network` panel. The agent-usage widget is
Omarchy's built-in `omarchy.agents`. The webcam toggle asks for privilege and
installs/enables its helper service when first used; setup does not trigger it.
The hotspot backend remains machine-local and is not bootstrapped here.

The display widget is installed with Omarchy's plugin manager from
`kris-1/omarchy-monitor-layout`; it is not vendored or automatically updated.
The checked-out version during repository review was `d71dba7`.

OpenCode credentials remain outside deployment and Git. Review `.gitignore` and
Stow exclusions before adding any local files. The current legacy
`dotfiles/bashrc/.bashrc` remains excluded from Stow: its live home symlink
contains Omarchy initialization and personal settings. The Bash hook installer
refuses symlinks. On this machine, migrate that file manually after backing it
up; fresh Omarchy installs can receive the simple hook automatically.

Neovim remains deferred: keep Omarchy's default, personal `nvim-ghoul`, and
Markdown `nvim-markdown` configurations independent. No plugins/configs are
selected here.

## QEMU check

Use a clean Omarchy VM snapshot. Preview first, run setup, then verify bar
widgets, keyboard bindings, tmux sessions, Bash aliases, Hyprland rules, and
nightlight. Run setup a second time to check repeatability. Test webcam blocking,
hotspot operation, and hardware-specific behavior only where the VM supports
them; otherwise verify those on the corresponding hardware.
