#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="git@github.com:jpcenteno80/dotfiles.git"
DOTFILES_DIR="$HOME/projects/dotfiles"
SSH_KEY="$HOME/.ssh/id_ed25519_github"

info() { printf "\033[1;34m[bootstrap]\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m[bootstrap]\033[0m %s\n" "$1"; }
err()  { printf "\033[1;31m[bootstrap]\033[0m %s\n" "$1" >&2; }

# ---------------------------------------------------------------------------
# Sudo mode
#
# Default: sudo path (assumes apt + sudo are available).
# Set DOTFILES_NO_SUDO=1 to use the user-space path on restricted servers.
# The flag is exported so install.sh inherits it.
# ---------------------------------------------------------------------------
export DOTFILES_NO_SUDO="${DOTFILES_NO_SUDO:-0}"
if [ "$DOTFILES_NO_SUDO" = "1" ]; then
    info "Running in no-sudo mode (user-space installs)."
else
    info "Running in sudo mode (set DOTFILES_NO_SUDO=1 to skip sudo)."
fi

# ---------------------------------------------------------------------------
# Ensure git is available
# ---------------------------------------------------------------------------
if ! command -v git &>/dev/null; then
    if [ "$DOTFILES_NO_SUDO" = "1" ]; then
        err "git is not installed and DOTFILES_NO_SUDO=1 — cannot install it without root."
        err "Ask your admin to install git, then re-run this bootstrap."
        exit 1
    fi
    info "Installing git..."
    sudo apt-get update -qq && sudo apt-get install -y -qq git
fi

# ---------------------------------------------------------------------------
# Generate SSH key for GitHub
# ---------------------------------------------------------------------------
if [ ! -f "$SSH_KEY" ]; then
    info "Generating SSH key..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -f "$SSH_KEY" -N "" -C "$(whoami)@$(hostname)"

    echo ""
    echo "========================================================"
    echo "  Add this public key to https://github.com/settings/keys"
    echo "========================================================"
    echo ""
    cat "${SSH_KEY}.pub"
    echo ""
    echo "========================================================"
    read -rp "Press Enter after you have added the key to GitHub..."
else
    info "SSH key already exists at $SSH_KEY"
fi

# ---------------------------------------------------------------------------
# Configure SSH to use this key for GitHub
# ---------------------------------------------------------------------------
mkdir -p "$HOME/.ssh"
if ! grep -q "Host github.com" "$HOME/.ssh/config" 2>/dev/null; then
    cat >> "$HOME/.ssh/config" <<'EOF'
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_github
  IdentitiesOnly yes
EOF
    chmod 600 "$HOME/.ssh/config"
    info "Added GitHub SSH config."
fi

# ---------------------------------------------------------------------------
# Clone dotfiles and run install
# ---------------------------------------------------------------------------
if [ ! -d "$DOTFILES_DIR" ]; then
    info "Cloning dotfiles..."
    mkdir -p "$HOME/projects"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    info "Dotfiles already cloned. Pulling latest..."
    git -C "$DOTFILES_DIR" pull
fi

info "Running dotfiles installer..."
chmod +x "$DOTFILES_DIR/install.sh"
"$DOTFILES_DIR/install.sh"
