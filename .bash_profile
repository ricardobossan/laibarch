#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Sets custom path for password-store
export PASSWORD_STORE_DIR="$HOME/.local/share/password-store"
export EDITOR="nvim"
export XKB_DEFAULT_LAYOUT=us
export XKB_DEFAULT_VARIANT=intl

# Adds local executables to PATH
export PATH=$PATH+=":${HOME}/.local/bin"

# Executes dwl on start with automatic display configuration
if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
  ~/.local/bin/dwl-autostart.sh &
  exec dwl
fi
