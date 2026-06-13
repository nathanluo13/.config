#!/usr/bin/env bash
#
# bootstrap.sh — bring a bare macOS machine (e.g. sword) up to katana's setup.
#
# This is the ONE command to run on a fresh Mac. It installs the prerequisites
# that chezmoi does not track (Homebrew, oh-my-zsh, oh-my-tmux, nvm/node), then
# applies the dotfiles and installs every package from the Brewfile.
#
# Usage on a bare machine:
#   curl -fsSL https://raw.githubusercontent.com/nathanluo13/dot-mac/main/bootstrap.sh | bash
# or, if you already cloned the repo:
#   bash bootstrap.sh
#
# Safe to re-run: every step is guarded and idempotent (also a no-op on katana).
set -euo pipefail

GH_USER="nathanluo13"
DOTFILES_REPO="${GH_USER}/dot-mac"
log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

# 1. Xcode Command Line Tools (git, compilers) -------------------------------
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools (accept the GUI prompt, then re-run)…"
  xcode-select --install || true
  echo "Re-run this script once the Command Line Tools finish installing." >&2
  exit 1
fi

# 2. Homebrew ----------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew…"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Load brew into this shell (Apple Silicon path) for the rest of the script.
eval "$(/opt/homebrew/bin/brew shellenv)"

# 3. chezmoi -----------------------------------------------------------------
if ! command -v chezmoi >/dev/null 2>&1; then
  log "Installing chezmoi…"
  brew install chezmoi
fi

# 4. oh-my-zsh (unattended — keeps existing .zshrc, chezmoi owns it) ---------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Installing oh-my-zsh…"
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 5. oh-my-tmux + symlink ----------------------------------------------------
OMT_DIR="$HOME/.local/share/tmux/oh-my-tmux"
if [ ! -d "$OMT_DIR" ]; then
  log "Cloning oh-my-tmux…"
  mkdir -p "$(dirname "$OMT_DIR")"
  git clone --depth 1 https://github.com/gpakosz/.tmux.git "$OMT_DIR"
fi
mkdir -p "$HOME/.config/tmux"
ln -sf "$OMT_DIR/.tmux.conf" "$HOME/.config/tmux/tmux.conf"
# (tmux.conf.local is applied by chezmoi in step 7.)

# 6. nvm + Node LTS ----------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  log "Installing nvm…"
  PROFILE=/dev/null bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh)"
fi
# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"
if ! nvm which --lts >/dev/null 2>&1; then
  log "Installing Node LTS…"
  nvm install --lts
fi

# 7. Apply dotfiles ----------------------------------------------------------
if [ ! -d "$(chezmoi source-path 2>/dev/null)" ]; then
  log "Initialising dotfiles from ${DOTFILES_REPO}…"
  chezmoi init --apply "$DOTFILES_REPO"
else
  log "Applying dotfiles…"
  chezmoi apply
fi

# 8. Install packages from the Brewfile (now on disk after apply) ------------
BREWFILE="$HOME/.config/homebrew/Brewfile"
if [ -f "$BREWFILE" ]; then
  # Newer Homebrew refuses casks from third-party taps until the tap is trusted.
  # Trust every tap the Brewfile declares before bundling.
  grep -E '^tap "' "$BREWFILE" | sed -E 's/^tap "([^"]+)".*/\1/' | while read -r t; do
    brew trust "$t" >/dev/null 2>&1 || true
  done
  log "Installing packages from Brewfile…"
  # Best-effort: pkg-installer casks (SF fonts, etc.) need sudo and vscode/npm
  # extras need their host app — don't abort the whole run if one fails.
  brew bundle --file="$BREWFILE" || \
    log "Some Brewfile entries failed (sudo pkg casks / vscode / npm extras) — review above."
fi

log "Done. Open a new terminal — katana's setup is live on this machine."
