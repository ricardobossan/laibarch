#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Sets custom path for password-store
export PASSWORD_STORE_DIR="$HOME/.local/share/password-store"
export EDITOR="nvim"

# Adds local executables to PATH
export PATH=$PATH+=":${HOME}/.local/bin"

# Executes dwl on start with automatic display configuration
if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
  (sleep 1 && ~/.local/bin/configure-displays.sh) &
  exec dwl
fi
