# dotfiles

Managed with [chezmoi](https://chezmoi.io). Source of truth for katana's config.

## Apply on macOS (bare Mac, e.g. sword)

One command — installs Homebrew, oh-my-zsh, oh-my-tmux, tmux-dotbar, nvm/node,
applies the dotfiles, then installs everything in the Brewfile:

```sh
curl -fsSL https://raw.githubusercontent.com/nathanluo13/dot-mac/main/bootstrap.sh | bash
```

If chezmoi is already present and you only want the config files:

```sh
chezmoi init --apply nathanluo13/dot-mac
```

## Daily use

```sh
chezmoi add <file>      # start tracking a file
chezmoi edit <file>     # edit the source copy
chezmoi diff            # preview pending changes
chezmoi apply           # write source -> home
chezmoi cd && git push  # commit + push the source repo
```

## Managed

- Shell: `.zshrc`, `.zprofile`, `.gitconfig`
- Apps: aerospace (+ fullscreen-watch.sh), kitty, nvim (LazyVim), btop, spotify-player, tmux (`tmux.conf.local`)
- Packages: `.config/homebrew/Brewfile` for macOS; `.config/wsl/apt-packages.txt`
  and `.config/wsl/npm-globals.txt` for Ubuntu WSL
- launchd: `com.nathan.aerospace-fullscreen-watch.plist`
- Bootstrap: `bootstrap.sh` (repo-only — installs prerequisites chezmoi can't track)

## Windows and WSL

- Windows host setup: see `WINDOWS.md` and `bootstrap-windows.ps1`.
- Ubuntu WSL setup: see `WSL.md` and `bootstrap-wsl.sh`.

## Deliberately NOT tracked (secrets / app-managed state)

- `~/.config/gh/` — OAuth tokens
- `~/.config/devin/` — secret config
- `~/.config/raycast/` — large app state, syncs via Raycast cloud

Per-machine differences (katana / ember / sword) go through chezmoi templates:
`{{ if eq .chezmoi.hostname "katana" }} ... {{ end }}`.
