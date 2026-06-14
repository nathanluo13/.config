$ESC = [char]27
$BEL = [char]7

# Flint window title used in plain, non-Orbh sessions. Orbh-managed sessions
# replace it through `flint orbh session register`.
function Set-FlintTabTitle {
    $leaf = Split-Path -Leaf $PWD.ProviderPath
    $title = "Flint - $leaf"
    $Host.UI.RawUI.WindowTitle = $title
    [Console]::Write("$ESC]0;$title$BEL")
}

Set-FlintTabTitle

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $themeName = if ($PSVersionTable.PSVersion.Major -ge 6) {
        "emodipt-extend.omp.json"
    } else {
        "jandedobbeleer.omp.json"
    }

    $ompTheme = if ($env:POSH_THEMES_PATH) {
        Join-Path $env:POSH_THEMES_PATH $themeName
    }

    if (-not ($ompTheme -and (Test-Path $ompTheme))) {
        $ompTheme = Join-Path $env:LOCALAPPDATA "Programs\oh-my-posh\themes\$themeName"
    }

    oh-my-posh init pwsh --config $ompTheme | Invoke-Expression
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# Report cwd to Windows Terminal (OSC 9;9) so Duplicate Tab and new tabs inherit
# the current directory. zoxide and OMP own the prompt, so wrap it instead of
# replacing it.
if ($env:WT_SESSION) {
    $script:__basePrompt = $function:prompt
    function prompt {
        $loc = $executionContext.SessionState.Path.CurrentLocation
        if ($loc.Provider.Name -eq 'FileSystem') {
            [Console]::Write("$([char]27)]9;9;$($loc.ProviderPath)$([char]7)")
        }
        & $script:__basePrompt
    }
}
