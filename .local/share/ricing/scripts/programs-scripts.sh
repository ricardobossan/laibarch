#!/bin/bash
set -e # Exit on error

echo "Installing programs from source..."
echo ""

# Create repos directory and use it as working directory
REPOS=${HOME}/source/repos
mkdir -p "$REPOS"
cd "$REPOS"

# yay (AUR helper)
echo "Installing yay..."
if command -v yay &>/dev/null; then
  echo "Yay already installed, skipping..."
else
  # Remove incomplete installation if it exists
  [ -d "$REPOS/yay-bin" ] && rm -rf "$REPOS/yay-bin"

  git clone https://aur.archlinux.org/yay-bin.git "$REPOS/yay-bin"
  cd "$REPOS/yay-bin"
  makepkg -si --noconfirm
  echo "Yay installed successfully!"
fi
echo ""

# neovim
echo "Installing neovim..."
if command -v nvim &>/dev/null && [ -d ~/.config/nvim ]; then
  echo "Neovim already installed, skipping..."
else
  curl -LO https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz
  tar zxf nvim-linux-x86_64.tar.gz

  mkdir -p ~/.local/bin ~/.local/lib ~/.local/share
  cp -r nvim-linux-x86_64/bin/* ~/.local/bin/
  cp -r nvim-linux-x86_64/lib/* ~/.local/lib/
  cp -r nvim-linux-x86_64/share/* ~/.local/share/

  rm -rf nvim-linux-x86_64.tar.gz nvim-linux-x86_64

  sudo ln -sf ${HOME}/.local/bin/nvim /usr/bin/nvim
  echo "Neovim installed successfully!"
fi
echo ""

# tree-sitter-cli
echo "Installing tree-sitter-cli..."
if command -v tree-sitter &>/dev/null; then
  echo "Tree-sitter-cli already installed, skipping..."
else
  sudo npm install -g tree-sitter-cli
  echo "Tree-sitter-cli installed successfully!"
fi
echo ""

# transmission
echo "Installing transmission..."
if command -v transmission-daemon &>/dev/null; then
  echo "Transmission already installed, skipping..."
else
  # Remove incomplete installation if it exists
  [ -d "$REPOS/Transmission" ] && rm -rf "$REPOS/Transmission"

  cd "$REPOS"
  git clone --recurse-submodules https://github.com/transmission/transmission Transmission
  cd Transmission
  cmake -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo
  cd build
  cmake --build .
  sudo cmake --install .
  echo "Transmission installed successfully!"
fi
echo ""

# tremc
echo "Installing tremc..."
if command -v tremc &>/dev/null; then
  echo "Tremc already installed, skipping..."
else
  TREMC_DIR=${REPOS}/tremc
  # Remove incomplete installation if it exists
  [ -d "$TREMC_DIR" ] && rm -rf "$TREMC_DIR"

  git clone https://github.com/tremc/tremc.git "$TREMC_DIR"
  cd "$TREMC_DIR"
  sudo make install
  echo "Tremc installed successfully!"
fi
echo ""

# Brave
echo "Installing brave browser..."
if command -v brave &>/dev/null; then
  echo "Brave already installed, skipping..."
else
  curl -fsS https://dl.brave.com/install.sh | sh
  echo "Brave installed successfully!"
fi
echo ""

# yt-x
echo "Installing yt-x youtube viewer/downloader browser..."
if command -v brave &>/dev/null; then
  echo "yt-x already installed, skipping..."
else
  yay yt-x --noconfirm
  echo "yt-x installed successfully!"
fi
echo ""

# rate-mirrors - SKIPPED (build fails with geolocation errors, available via pacman)
# Install manually if needed: sudo pacman -S rate-mirrors
echo "Skipping rate-mirrors (available via pacman if needed)"
echo ""

echo "All programs installed successfully!"
