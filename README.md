# Supplement

Personal Arch/Omarchy post-install configuration. Portable user-owned files live
in `dotfiles/` and are linked with GNU Stow; small Omarchy-specific patches live
in `overrides/`. The bootstrap intentionally does not remove packages, enable
services, install mise runtimes, or automate GUI setup.

## First setup

Review the package manifests and local credentials before running anything:

```bash
./scripts/setup.sh --dry-run
```

Then, when ready to install the listed packages and configure the home directory:

```bash
./scripts/setup.sh
```

`--skip-packages` deploys the Stow files and runs configuration steps without
package transactions. The normal run asks pacman/yay to install only listed
packages using their normal confirmation behavior. No removal manifest is
executed. Omarchy-only changes are skipped on plain Arch.

The scripts assume Arch Linux with sudo access, GNU Stow, and Bash. AUR packages
require `yay`. `scripts/stow.sh --dry-run` previews links independently. Review
conflicts; Stow never uses `--adopt` and will not replace conflicting regular
files. Existing files remain in place unless Stow can safely create its links.

## Structure and maintenance

- `dotfiles/`: portable, user-owned Stow packages, rooted at `$HOME`.
- `overrides/omarchy/`: narrowly scoped patches to Omarchy-owned files.
- `scripts/packages/`: manually curated pacman/yay package lists. These are not
  copies of the installed-package inventory; kernel, Omarchy, and machine-specific
  drivers/defaults are deliberately excluded.
- `scripts/setup.sh`: bootstrap entry point; `--dry-run` previews instead of
  performing writes or package transactions.

Re-run setup after editing manifests or dotfiles. `pacman -S --needed` and yay's
`--needed` make package installation repeatable. Review the manifests against
your current needs rather than adding every package from `~/installed_packages`.
`~/native_packages`, `~/foreign_packages`, `~/installed_packages`,
`~/mise_runtimes`, and `~/npm_packages` were reviewed as inventory references;
foreign status does not prove a package came from AUR.

The Omarchy nightlight patch checks for exactly one `ON_TEMP=4000` or already
patched `ON_TEMP=1000`, preserves unrelated lines and file metadata, and is safe
to rerun. The installed executable belongs to the `omarchy` package. No pacman
post-transaction hook is installed: after an Omarchy update, preview and rerun
`sudo ./overrides/omarchy/patch-nightlight.sh` if the upstream value reverted.
That manual reapplication avoids silently patching an unexpected upstream edit.

The skill patcher touches only Omarchy's `diagnose-crash` and `omarchy` skill
front matter, preserving their bodies and unrelated metadata. The files are
owned by `omarchy-settings`; rerun the patch after that package updates them.
Preview with `python3 overrides/omarchy/patch-skill-metadata.py --dry-run`.

## Configuration notes and safety

- The current home `.bashrc` is a legacy Stow link into `dotfiles/bashrc/` and
  contains Omarchy initialization plus the old personal settings. That file is
  retained during migration so the active shell is not broken. The personal
  settings are also represented in `~/.config/bash/supplement.sh`; when ready,
  review and remove the duplicate legacy definitions as a separate migration.
  `scripts/configs/install-bash-hook.sh` appends one marked hook without
  replacing the file; `BASHRC_FILE` supports fixture testing. The intended end
  state is for Omarchy's `.bashrc` initialization to source this independent
  supplement.
- Omarchy's Lua entry point loads `hyprland.lua` modules from the user's config.
  The live entry point already loads `hyprland_overrides`; the files now reside
  under Stow-managed `~/.config/hypr/supplement/`, so no repository path patch is
  needed. The main Omarchy entry point is not deployed by this repository.
- The mise config keeps the actual configured versions, including the OpenCode
  build allowance and disabled auto-pruning. Runtime installation/upgrades are
  intentionally explicit because several entries use `latest`.
- `github-cli` is installed through pacman while mise also manages `gh`; this is
  a duplicate provider. Neither is removed or altered automatically. Playwright
  CLI is separately declared in mise; unlike the Docker MCP, it can serve local
  shell-driven browser/test workflows. No repository use was found, so retain
  it until deciding whether that independent use matters.
- OpenCode's `server.env` and `github-pat.env` are deliberately excluded from
  Stow deployment. They are still present in the current working tree and must
  be moved by the user to their existing external home config location before
  any future cleanup. `.gitignore` is not a deployment safety mechanism. Do not
  put credentials in Git; rotate any credential that may have been exposed.
- Portable `opencode.service` and `voxtype.service` definitions are Stow-managed.
  They currently conflict with existing regular files, so inspect/back up and
  manually migrate them before those links can be installed. After deployment,
  run `systemctl --user daemon-reload` and separately decide whether to enable or
  restart anything. OpenCode credentials remain in its external EnvironmentFile.
  `hermes-gateway.service` is tied to a local Hermes install; `bt-agent.service`
  is package-owned. Setup does not reload, enable, or restart services.

## Manual setup and later work

- JetBrains Toolbox manages IntelliJ IDEA, PyCharm, and WebStorm; sign in and
  install the desired IDEs through Toolbox. Reliable GUI automation is not used.
- Provide local OpenCode server credentials outside this repository before
  starting its user service. Review MCP enablement and authentication locally.
- Install mise runtimes deliberately after reviewing `mise ls` and the config.
- Verify hardware-specific drivers, bootloader, networking, and Omarchy defaults
  on each machine; they are not generic application selections.
- Neovim is architecture-only for now: preserve Omarchy's default at
  `~/.config/nvim`, build the personal configuration at
  `~/.config/nvim-ghoul`, and the independent Markdown editor at
  `~/.config/nvim-markdown`. Launcher conventions are `NVIM_APPNAME=nvim-ghoul
  nvim` and `NVIM_APPNAME=nvim-markdown nvim` (already reflected by the Bash
  aliases). No plugins or configurations are selected in this phase.
- A future vanilla-Arch phase can gradually remove Omarchy-specific assumptions;
  Nix/Home Manager is intentionally out of scope.

## Recovery

Use `stow -D -d "$PWD/dotfiles" -t "$HOME" PACKAGE` to unlink a package; inspect
the package and target first. GNU Stow removes only links it owns. Existing
regular-file conflicts (currently mise and parts of OpenCode) intentionally
block those packages; back up and compare each target, then arrange a manual
migration before rerunning Stow. Do not use `--adopt` or overwrite a conflict.
To remove the Bash hook, delete only the lines between its two supplement hook
markers after inspecting `~/.bashrc`. Omarchy patch scripts do not create backups;
package updates restore their owned files, and the nightlight patch edits only
the one verified assignment.
