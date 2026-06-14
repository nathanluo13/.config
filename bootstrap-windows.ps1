$ErrorActionPreference = "Stop"

$repo = "nathanluo13/.config"

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget is required. Install App Installer from Microsoft Store first."
}

winget install --id Git.Git --source winget --accept-package-agreements --accept-source-agreements
winget install --id twpayne.chezmoi --source winget --accept-package-agreements --accept-source-agreements
winget install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements

$chezmoi = Get-Command chezmoi -ErrorAction Stop
& $chezmoi.Source init --apply $repo
