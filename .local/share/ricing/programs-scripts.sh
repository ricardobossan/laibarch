#!/bin/bash
set -e  # Exit on error

echo "Installing programs from source..."
echo ""

# Create repos directory
REPOS=${HOME}/source/repos
mkdir -p "$REPOS"

# neovim
echo "Installing neovim..."
curl -LO https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz
tar zxf nvim-linux-x86_64.tar.gz

mkdir -p ~/.local/bin ~/.local/lib ~/.local/share
cp -r nvim-linux-x86_64/bin/* ~/.local/bin/
cp -r nvim-linux-x86_64/lib/* ~/.local/lib/
cp -r nvim-linux-x86_64/share/* ~/.local/share/

rm -rf nvim-linux-x86_64.tar.gz nvim-linux-x86_64

sudo ln -sf ${HOME}/.local/bin/nvim /usr/bin/nvim
echo "Neovim installed successfully!"
echo ""

# tree-sitter-cli
echo "Installing tree-sitter-cli..."
sudo npm install -g tree-sitter-cli
echo ""

# transmission
echo "Installing transmission..."
cd "$REPOS"
git clone --recurse-submodules https://github.com/transmission/transmission Transmission
cd Transmission
cmake -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo
cd build
cmake --build .
sudo cmake --install .
echo "Transmission installed successfully!"
echo ""

# tremc
echo "Installing tremc..."
TREMC_DIR=${REPOS}/tremc
git clone https://github.com/tremc/tremc.git "$TREMC_DIR"
cd "$TREMC_DIR"
sudo make install
echo "Tremc installed successfully!"
echo ""

# Brave
echo "Installing brave browser..."
curl -fsS https://dl.brave.com/install.sh | sh
echo ""

# rate-mirrors
echo "Installing rate-mirrors..."
RATE_MIRRORS_DIR=${REPOS}/rate-mirrors
git clone https://github.com/westandskif/rate-mirrors.git "$RATE_MIRRORS_DIR"
cd "$RATE_MIRRORS_DIR"
cargo build --release --locked
sudo cp target/release/rate-mirrors /usr/local/bin/
echo "Rate-mirrors installed successfully!"
echo ""

# workstyle
echo "Installing workstyle..."
WORKSTYLE_DIR=${REPOS}/workstyle
git clone https://github.com/pierrechevalier83/workstyle.git "$WORKSTYLE_DIR"
cd "$WORKSTYLE_DIR"
cargo install workstyle
echo "Workstyle installed successfully!"
echo ""

echo "All programs installed successfully!"
