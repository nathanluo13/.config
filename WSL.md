# WSL development setup

The `work` Windows machine should use WSL for day-to-day development. Windows
still owns Windows app install, drivers, Visual Studio Build Tools, and other
host-level configuration. WSL owns the Unix development toolchain.

## Bootstrap

From inside Ubuntu WSL:

```sh
curl -fsSL https://raw.githubusercontent.com/nathanluo13/.config/main/bootstrap-wsl.sh | bash
```

The bootstrap installs Ubuntu packages for shell/dev work, then installs
chezmoi, oh-my-zsh, oh-my-tmux, tmux-dotbar, nvm, Node, pnpm, and npm globals.
It applies the same chezmoi repo with Linux-safe shell and tmux config.

The WSL package source is split by installer:

- `~/.config/wsl/apt-packages.txt` maps the CLI/dev parts of the Brewfile to
  Ubuntu packages.
- `~/.config/wsl/npm-globals.txt` maps the Brewfile's npm global CLIs.
- `nvm`, Node, corepack, and pnpm are installed by `bootstrap-wsl.sh` because
  they need shell/runtime setup, not apt.

See `~/.config/wsl/README.md` for the full Brewfile-to-WSL mapping.

The macOS Brewfile remains the source for Mac apps, casks, taps, and
macOS-specific utilities. Items like AeroSpace, SF Symbols, `switchaudio-osx`,
`nowplaying-cli`, and menu bar apps do not have a WSL equivalent and should stay
on the Windows/macOS host side.

If bootstrapping remotely from katana before this branch is pushed, install the
system packages as root, then run the user-level bootstrap with `SKIP_APT=1`
and copy/apply this local source tree into WSL.

## Filesystem model

Prefer active development repos in the WSL filesystem:

```text
~/c/project
~/device/flint-or-repo
~/src/project
```

Windows can browse those files at:

```text
\\wsl$\Ubuntu\home\natha
```

WSL can also operate on Windows files under `/mnt/c`, but treat that as
compatibility mode. It is useful for Obsidian vaults or quick edits, but active
Node/build/file-watcher work is cleaner and faster inside WSL's own filesystem.

## SSH access

The reliable default path is:

```sh
ssh work
wsl.exe --cd ~ --exec zsh -l
```

Or from one command:

```sh
ssh -t work 'wsl.exe --cd ~ --exec zsh -l'
```

That SSHs into the Windows host over Tailscale, then enters Ubuntu through
`wsl.exe`. It does not require exposing WSL's NATed network to the Tailnet.

Direct SSH into WSL is possible, but it needs extra networking:

- run `sshd` inside WSL
- expose a Windows port proxy from the Windows host to the WSL IP, or run
  Tailscale inside WSL itself
- keep the proxy updated when WSL's NAT address changes

For most work, the Windows SSH plus `wsl.exe` path is simpler and more robust.

## PowerShell use

PowerShell remains useful for Windows host work:

- `winget` and Windows app installation
- Windows services, drivers, firewall, port proxy, and registry changes
- Visual Studio Build Tools and Windows SDK maintenance
- launching or repairing WSL itself

Normal development should happen in WSL.
