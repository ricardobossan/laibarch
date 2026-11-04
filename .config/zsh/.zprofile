#
# ${ZDOTDIR}/.zprofile
# Login shell only. Commands that run once at login.
#

# Start SSH agent if not running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi

# Start DWL on TTY1
if [[ -o interactive ]] && [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
    # slstatus queries the default sink from its first tick, so wait for
    # WirePlumber to pick one (up to 5s, for machines with no audio device).
    for _ in {1..50}; do
        wpctl inspect @DEFAULT_AUDIO_SINK@ >/dev/null 2>&1 && break
        sleep 0.1
    done

    echo "$(date): Starting dwl" >> /tmp/dwl-debug.log
    slstatus -s | dwl -s ~/.local/bin/dwl-autostart.sh
    echo "$(date): dwl exited with code $?" >> /tmp/dwl-debug.log
fi
