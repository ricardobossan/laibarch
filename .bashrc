#
# ${HOME}/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# mupdf wrapper with automatic XWayland management
mupdf() {
  if [ $# -eq 0 ]; then
    echo "usage: mupdf [options] file.pdf [page]"
    return 1
  fi

  local display_num=":99"
  local xwayland_pid=""
  local started_xwayland=false

  # Check if XWayland is already running on our display
  if ! pgrep -f "Xwayland ${display_num}" >/dev/null; then
    # Start XWayland in background
    Xwayland ${display_num} -ac >/dev/null 2>&1 &
    xwayland_pid=$!
    started_xwayland=true

    # Wait a bit for XWayland to initialize
    sleep 0.5
  fi

  # Run mupdf with the display
  DISPLAY=${display_num} /usr/bin/mupdf "$@"

  # If we started XWayland, kill it when mupdf exits
  if [ "$started_xwayland" = true ] && [ -n "$xwayland_pid" ]; then
    kill $xwayland_pid 2>/dev/null
  fi
}

# General
alias \
  cls='clear && exa -1A' \
  exa="exa -A1" \
  exmon='wlr-randr --output eDP-1 --off' \
  grep='grep --color=auto' \
  leet="nvim +Leet" \
  ls='ls --color=auto' \
  lg='lazygit' \
  sourcez="source ${HOME}/.bashrc" \
  wttr="curl wttr.in" \
  v="nvim" \
  vim="nvim" \
  obsidian="obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland" \
  calcurse="calcurse -D ${HOME}/Documents/calcurse" \
  fd="fd -iH" \
  rg="rg -iH"

# Shortcuts
alias \
  cfb="\$EDITOR ${HOME}/.bashrc" \
  ric="cd ${HOME}/Documents/ricardo && ${EDITOR} vault-root.md +ObsidianToday" \
  ether="cd ${HOME}/Documents/mai/ether && ${EDITOR} ." \
  bys="cd ${HOME}/Documents/bys && ${EDITOR} ." \
  docs="cd ${HOME}/Documents/zettelkasten && ${EDITOR} ." \
  cf="cd ${HOME}/.config" \
  repo="cd ${HOME}/source/repos" \
  rice="cd ${HOME}/.local/share/ricing"

# Shows git branch on shell prompt
source /usr/share/git/completion/git-prompt.sh
PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '

# Automatically start tmux if not already inside tmux
# Only auto-start in terminal emulators (pts), not on login TTY
if [ -z "$TMUX" ] && [[ $(tty) == /dev/pts/* ]]; then
  exec tmux
fi
