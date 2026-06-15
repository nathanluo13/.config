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
chezmoi, oh-my-zsh, oh-my-tmux, tmux-dotbar, nvm, Node, and pnpm. It applies the
same chezmoi repo with Linux-safe shell and tmux config.

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
wsl.exe --cd ~ --exec bash -l
```

Or from one command:

```sh
ssh -t work 'wsl.exe --cd ~ --exec bash -l'
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
