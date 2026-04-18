#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Source shared environment variables
[[ -f "$HOME/.config/shell/profile" ]] && . "$HOME/.config/shell/profile"

# Start SSH agent if not running
if ! pgrep -u "$USER" ssh-agent >/dev/null; then
  ssh-agent -t 1h >"$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
  source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi

# Executes dwl on start with automatic display configuration
if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
  echo "$(date): Starting dwl" >>/tmp/dwl-debug.log
  slstatus -s | dwl -s ~/.local/bin/dwl-autostart.sh
  echo "$(date): dwl exited with code $?" >>/tmp/dwl-debug.log
fi
