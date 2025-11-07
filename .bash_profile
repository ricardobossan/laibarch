#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# TODO: Remember to remove this when not using external monitor
# Sets custom path for password-store
export PASSWORD_STORE_DIR="$HOME/.local/share/password-store"
export EDITOR="nvim"

# Adds local executables to PATH
export PATH=$PATH+=":${HOME}/.local/bin"

# Executes dwl on start with display configuration
if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
  (sleep 3 && wlr-randr --output eDP-1 --off --output HDMI-A-1 --on --preferred) &
  exec dwl
fi
