#!/bin/bash

# Detect machine
unameOut="$(uname -s)"
case "${unameOut}" in
  Linux*)     MACHINE=Linux;;
  Darwin*)    MACHINE=Mac;;
  CYGWIN*)    MACHINE=Cygwin;;
  MINGW*)     MACHINE=MinGw;;
  *)          MACHINE="UNKNOWN:${unameOut}"
esac

echo $MACHINE
GREEN='\033[0;32m'
RESET='\033[0m'
echo -e "${GREEN}\nAfter installation complete! Please perform the following actions to complete the configuration:\n"
echo -e "echo \"autoload -Uz colors && colors\nsetopt PROMPT_SUBST\nPROMPT='%{\$fg[green]%}%n@%m %{\$fg[blue]%}%~%{\$reset_color%} '\n alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'\" >> ~/.zshrc"
echo -e "add zsh-autosuggestions tzsh-syntax-highlighting into ~/.zshrc"
echo -e "\n run 'source ~/.zshrc' to apply the changes.${RESET}\n"

# Installs .oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  # Installs Oh my ZSH with Homebrew (Mac)
  if [[ $MACHINE == "Mac" ]]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  # Installs Oh my ZSH with Linux
  if [[ $MACHINE == "Linux" ]]; then
    sudo apt install zsh -y
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  fi
fi

# Assumes default ZSH installation
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Installs plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Fix permissions
chmod 700 ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
