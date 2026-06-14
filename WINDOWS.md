# Windows dotfiles

Windows config is managed by the same chezmoi repo as macOS, with OS-specific
paths gated in `.chezmoiignore`.

## Bootstrap

Run from a PowerShell terminal:

```powershell
iwr https://raw.githubusercontent.com/nathanluo13/.config/main/bootstrap-windows.ps1 | iex
```

The bootstrap installs Git, chezmoi, and PowerShell through winget, then runs:

```powershell
chezmoi init --apply nathanluo13/.config
```

## Managed Windows files

- `Documents/PowerShell/Microsoft.PowerShell_profile.ps1`
- `Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1`
- `.config/powershell/profile.ps1`
- `.config/winget/packages.json`
- `.config/scoop/config.json`
- `.config/scoop/apps.json`

The two PowerShell profile entrypoints dot-source the shared profile in
`.config/powershell/profile.ps1`. That profile sets the Flint tab title,
initializes oh-my-posh, initializes zoxide when present, and reports cwd to
Windows Terminal.

## Package refresh

From the Windows machine:

```powershell
winget export -o "$HOME\.config\winget\packages.json" --accept-source-agreements
scoop export > "$HOME\.config\scoop\apps.json"
chezmoi add "$HOME\.config\winget\packages.json"
chezmoi add "$HOME\.config\scoop\config.json"
chezmoi add "$HOME\.config\scoop\apps.json"
```
