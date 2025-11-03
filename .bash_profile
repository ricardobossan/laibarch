#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export PASSWORD_STORE_DIR="$HOME/.local/share/password-store"

# Executes dwl on start
if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
	exec dwl
fi
