#!/bin/bash
curl -LO https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz

# neovim
tar zxf nvim-linux-x86_64.tar.gz

mkdir -p ~/.local/bin ~/.local/lib ~/.local/share
cp -r nvim-linux-x86_64/bin/* ~/.local/bin/
cp -r nvim-linux-x86_64/lib/* ~/.local/lib/
cp -r nvim-linux-x86_64/share/* ~/.local/share/

rm nvim-linux-x86_64.tar.gz

sudo ln -s ${HOME}/.local/bin/nvim /usr/bin/nvim

echo "Neovim installed successfully!"

# tree-sitter-cli
sudo npm install -g tree-sitter-cli

REPOS=${HOME}/source/repos

# transmission
$ git clone --recurse-submodules https://github.com/transmission/transmission Transmission
$ cd Transmission
# Use -DCMAKE_BUILD_TYPE=RelWithDebInfo to build optimized binary with debug information. (preferred)
# Use -DCMAKE_BUILD_TYPE=Release to build full optimized binary.
$ cmake -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo
$ cd build
$ cmake --build .
$ sudo cmake --install .

# tremc
TREMC_DIR=${REPOS}/tremc
git clone git@github.com:tremc/tremc.git $TREMC_DIR
cd $TREMC_DIR
sudo make install

# Brave
curl -fsS https://dl.brave.com/install.sh | sh

# rate-mirrors
RATE_MIRRORS_DIR=${REPOS}/rate-mirrors
git clone git@github.com:westandskif/rate-mirrors.git $RATE_MIRRORS_DIR
cd $RATE_MIRRORS_DIR
cargo build --release --locked

# workstyle
WORKSTYLE_REPOS=${REPOS}/workstyle
git clone git@github.com:pierrechevalier83/workstyle.git $WORKSTYLE_REPOS
cd $WORKSTYLE_REPOS
cargo install workstyle
