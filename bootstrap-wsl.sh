#!/usr/bin/env bash
#
# bootstrap-wsl.sh - bring an Ubuntu WSL distro up to the shared dev setup.
#
# Usage inside WSL:
#   curl -fsSL https://raw.githubusercontent.com/nathanluo13/.config/main/bootstrap-wsl.sh | bash
# or, if you already cloned the repo:
#   bash bootstrap-wsl.sh
#
# Safe to re-run. Package installation may prompt for sudo.
set -euo pipefail

GH_USER="nathanluo13"
DOTFILES_REPO="${GH_USER}/.config"
NODE_VERSION="${NODE_VERSION:-22}"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }

mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

if [ "$(uname -s)" != "Linux" ]; then
  echo "bootstrap-wsl.sh is for Linux/WSL only." >&2
  exit 1
fi

if ! grep -qi microsoft /proc/version 2>/dev/null; then
  warn "This does not look like WSL; continuing because it is Linux."
fi

if command -v sudo >/dev/null 2>&1; then
  SUDO=sudo
else
  SUDO=
fi

if [ "${SKIP_APT:-0}" = "1" ]; then
  log "Skipping apt package installation because SKIP_APT=1."
elif command -v apt-get >/dev/null 2>&1; then
  log "Installing Ubuntu development packages..."
  $SUDO apt-get update
  $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    fd-find \
    fzf \
    git \
    jq \
    neovim \
    openssh-client \
    openssh-server \
    ripgrep \
    tmux \
    unzip \
    zoxide \
    zsh
else
  warn "apt-get not found; skipping system package installation."
fi

if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

if ! command -v chezmoi >/dev/null 2>&1; then
  log "Installing chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Installing oh-my-zsh..."
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

OMT_DIR="$HOME/.local/share/tmux/oh-my-tmux"
if [ ! -d "$OMT_DIR" ]; then
  log "Cloning oh-my-tmux..."
  mkdir -p "$(dirname "$OMT_DIR")"
  git clone --depth 1 https://github.com/gpakosz/.tmux.git "$OMT_DIR"
fi

mkdir -p "$HOME/.config/tmux/plugins"
TMUX_DOTBAR_DIR="$HOME/.config/tmux/plugins/tmux-dotbar"
if [ ! -d "$TMUX_DOTBAR_DIR" ]; then
  log "Cloning tmux-dotbar..."
  git clone --depth 1 https://github.com/vaaleyard/tmux-dotbar.git "$TMUX_DOTBAR_DIR"
fi
ln -sf "$OMT_DIR/.tmux.conf" "$HOME/.config/tmux/tmux.conf"

export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  log "Installing nvm..."
  PROFILE=/dev/null bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh)"
fi
# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"
if ! nvm which "$NODE_VERSION" >/dev/null 2>&1; then
  log "Installing Node ${NODE_VERSION}..."
  nvm install "$NODE_VERSION"
fi
nvm alias default "$NODE_VERSION" >/dev/null
nvm use default >/dev/null
corepack enable
corepack prepare pnpm@latest --activate

if [ ! -d "$(chezmoi source-path 2>/dev/null)" ]; then
  log "Initialising dotfiles from ${DOTFILES_REPO}..."
  chezmoi init --apply "$DOTFILES_REPO"
else
  log "Applying dotfiles..."
  chezmoi apply
fi

if command -v zsh >/dev/null 2>&1 && [ "${SHELL:-}" != "$(command -v zsh)" ]; then
  warn "zsh is installed but is not your login shell. Run: chsh -s $(command -v zsh)"
fi

if [ ! -x "$HOME/.nuucognition/ndv/bin/flint" ]; then
  warn "NUU Flint CLI is not installed natively in WSL. Install/sync the private NUU dev bundle if you want Linux-native flint."
fi

log "Done. Open a new WSL terminal."
