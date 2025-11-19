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
export PATH=$PATH+=":${HOME}/.local/bin;${HOME}/.cargo/bin"

# Start SSH agent if not running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
  ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
  source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi

# Executes dwl on start with automatic display configuration
if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
  echo "$(date): Starting dwl" >> /tmp/dwl-debug.log
  slstatus -s | dwl -s ~/.local/bin/dwl-autostart.sh
  echo "$(date): dwl exited with code $?" >> /tmp/dwl-debug.log
fi
