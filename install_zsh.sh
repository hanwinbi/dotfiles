#!/bin/bash

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

# Functions
log_info() {
  echo -e "${GREEN}[INFO]${RESET} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${RESET} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${RESET} $1"
}

# Detect OS
detect_os() {
  unameOut="$(uname -s)"
  case "${unameOut}" in
    Linux*)   MACHINE=Linux;;
    Darwin*)  MACHINE=Mac;;
    *)        MACHINE="UNKNOWN:${unameOut}";;
  esac
  echo "$MACHINE"
}

# Check if command exists
command_exists() {
  command -v "$1" > /dev/null 2>&1
}

# Check if user is root or has sudo privileges
check_sudo_privileges() {
  # Check if running as root
  if [ "$EUID" -eq 0 ]; then
    SUDO=""
    log_info "Running as root user"
    return 0
  fi

  # Check if sudo is available and user has privileges
  if command_exists sudo; then
    # Check if user can run sudo without password (non-interactive)
    if sudo -n true 2>/dev/null; then
      SUDO="sudo"
      log_info "User has sudo privileges (no password required)"
      return 0
    else
      # Check if user can run sudo with password
      if sudo -l &>/dev/null; then
        SUDO="sudo"
        log_info "User has sudo privileges (password may be required)"
        return 0
      fi
    fi
  fi

  log_error "This script requires root or sudo privileges"
  log_error "Please run: sudo bash $0"
  exit 1
}

# Install dependencies for Linux
install_linux_deps() {
  if command_exists apt-get; then
    log_info "Detected apt-based system, installing dependencies..."
    $SUDO apt-get update
    $SUDO apt-get install -y zsh git curl
  elif command_exists yum; then
    log_info "Detected yum-based system, installing dependencies..."
    $SUDO yum install -y zsh git curl
  elif command_exists pacman; then
    log_info "Detected pacman-based system, installing dependencies..."
    $SUDO pacman -Sy --noconfirm zsh git curl
  elif command_exists brew; then
    log_info "Detected homebrew on Linux, installing dependencies..."
    brew install zsh git curl
  else
    log_error "Could not detect package manager. Please install zsh, git, and curl manually."
    return 1
  fi
}

# Install dependencies for macOS
install_mac_deps() {
  if ! command_exists brew; then
    log_error "Homebrew not found. Please install Homebrew first."
    return 1
  fi
  log_info "Installing dependencies with Homebrew..."
  brew install zsh git curl
}

# Main script
check_sudo_privileges

MACHINE=$(detect_os)
log_info "Detected OS: $MACHINE"

# Check and install required tools
if ! command_exists git; then
  log_warn "git not found, attempting to install..."
  if [[ $MACHINE == "Mac" ]]; then
    install_mac_deps || exit 1
  elif [[ $MACHINE == "Linux" ]]; then
    install_linux_deps || exit 1
  fi
fi

if ! command_exists curl; then
  log_warn "curl not found, attempting to install..."
  if [[ $MACHINE == "Mac" ]]; then
    install_mac_deps || exit 1
  elif [[ $MACHINE == "Linux" ]]; then
    install_linux_deps || exit 1
  fi
fi

# Check and install zsh
if ! command_exists zsh; then
  log_warn "zsh not found, attempting to install..."
  if [[ $MACHINE == "Mac" ]]; then
    install_mac_deps || exit 1
  elif [[ $MACHINE == "Linux" ]]; then
    install_linux_deps || exit 1
  else
    log_error "Unsupported OS: $MACHINE"
    exit 1
  fi
else
  log_info "zsh is already installed: $(zsh --version)"
fi

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log_info "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  log_info "Oh My Zsh is already installed"
fi

# Set ZSH custom directory
ZSH_CUSTOM="${HOME}/.oh-my-zsh/custom"

# Install plugins
PLUGINS_DIR="${ZSH_CUSTOM}/plugins"

# Install zsh-autosuggestions
if [ ! -d "${PLUGINS_DIR}/zsh-autosuggestions" ]; then
  log_info "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "${PLUGINS_DIR}/zsh-autosuggestions"
else
  log_info "zsh-autosuggestions already installed, skipping..."
fi

# Install zsh-syntax-highlighting
if [ ! -d "${PLUGINS_DIR}/zsh-syntax-highlighting" ]; then
  log_info "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${PLUGINS_DIR}/zsh-syntax-highlighting"
else
  log_info "zsh-syntax-highlighting already installed, skipping..."
fi

# Fix permissions
chmod 700 "${PLUGINS_DIR}/zsh-syntax-highlighting" 2>/dev/null || true

# Update .zshrc with plugins if not already configured
if [ -f "$HOME/.zshrc" ]; then
  if ! grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
    log_info "Adding plugins to .zshrc..."
    # Backup original zshrc
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak"

    # Update plugins line
    sed -i.bak "s/^plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions zsh-syntax-highlighting)/" "$HOME/.zshrc"
  else
    log_info "Plugins already configured in .zshrc"
  fi
else
  log_warn ".zshrc not found, skipping plugin configuration"
fi

# Add custom theme configuration if not already present
if ! grep -q "autoload -Uz colors" "$HOME/.zshrc"; then
  log_info "Adding custom theme configuration..."
  {
    echo ""
    echo "# Custom theme configuration"
    echo "autoload -Uz colors && colors"
    echo "setopt PROMPT_SUBST"
    echo "PROMPT='%{\$fg[green]%}%n@%m %{\$fg[blue]%}%~%{\$reset_color%} '"
    echo "alias dot='/usr/bin/git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'"
  } >> "$HOME/.zshrc"
else
  log_info "Custom theme already configured"
fi

log_info "Installation complete!"
log_info "To apply changes, run: exec \$SHELL or source ~/.zshrc"
