# WSL package mapping

This directory is the Ubuntu WSL counterpart to `.config/homebrew/Brewfile`.

## Installed by apt

`apt-packages.txt` covers the Brewfile CLI/dev tools that have Ubuntu packages:

- `btop`
- `fd` via Ubuntu's `fd-find` package
- `fzf`
- `gh`
- `jq`
- `lazygit`
- `llama.cpp`
- `lua` via Ubuntu's `lua5.4` package
- `neovim`
- `ripgrep`
- `tmux`
- `tree`
- `zoxide`

It also includes WSL bootstrap essentials that Homebrew does not model directly:
`build-essential`, `ca-certificates`, `curl`, `git`, OpenSSH, `unzip`, and `zsh`.

## Installed by bootstrap-wsl.sh

Some tools are better installed by the bootstrap script than by apt:

- `chezmoi`, installed from the upstream installer into `~/.local/bin`
- `nvm`, Node, and corepack
- `pnpm`, activated through corepack
- oh-my-zsh, oh-my-tmux, and tmux-dotbar

## Installed by npm

`npm-globals.txt` covers Brewfile npm globals:

- `agent-browser`
- `vercel`

`corepack` and `pnpm` are intentionally not npm globals here because Node ships
corepack and the bootstrap activates pnpm through it.

## Not installed in WSL by default

These Brewfile entries are host-specific or need a deliberate service decision:

- macOS apps/casks and fonts: AeroSpace, CC Switch, CodexBar, SF Symbols, SonoBus,
  and the font casks
- macOS-only CLIs: `nowplaying-cli`, `switchaudio-osx`
- host/service tools: `cliproxyapi`, `ollama`, `spotify_player`
- VS Code extensions, which belong to the Windows/macOS VS Code host or its
  Remote WSL extension context
- `zsh-vi-mode`, because the current `.zshrc` does not enable that plugin
