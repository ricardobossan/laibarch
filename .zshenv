#
# ~/.zshenv
# Read by all zsh instances. Environment variables go here.
#

export ZDOTDIR="$HOME/.config/zsh"

# Environment variables
export PASSWORD_STORE_DIR="$HOME/.local/share/password-store"
export EDITOR="nvim"
export XKB_DEFAULT_LAYOUT=us
export XKB_DEFAULT_VARIANT=intl
export DRI_PRIME=1

# PATH
export PATH="$PATH:${HOME}/.local/bin:${HOME}/.cargo/bin"
