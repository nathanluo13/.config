# dotfiles

Managed with [chezmoi](https://chezmoi.io). Source of truth for katana's config.

## Apply on a new machine

```sh
brew install chezmoi
chezmoi init --apply <this-repo-url>
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
- Apps: aerospace (+ fullscreen-watch.sh), kitty, nvim (LazyVim), btop, spotify-player
- launchd: `com.nathan.aerospace-fullscreen-watch.plist`

## Deliberately NOT tracked (secrets / app-managed state)

- `~/.config/gh/` — OAuth tokens
- `~/.config/devin/` — secret config
- `~/.config/raycast/` — large app state, syncs via Raycast cloud

Per-machine differences (katana / ember / sword) go through chezmoi templates:
`{{ if eq .chezmoi.hostname "katana" }} ... {{ end }}`.
