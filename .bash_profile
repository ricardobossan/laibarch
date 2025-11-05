#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Sets custom path for password-store
export PASSWORD_STORE_DIR="$HOME/.local/share/password-store"

# Adds local executables to PATH
export PATH=$PATH+=":${HOME}/.local/bin"

# Executes dwl on start
if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
  exec dwl
fi
