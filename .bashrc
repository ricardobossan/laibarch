#
# ${HOME}/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

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
  vim="nvim"

# Shortcuts
alias \
  cfb="\$EDITOR ${HOME}/.bashrc" \
  ric="cd ${HOME}/Documents/ricardo && ${EDITOR} vault-root.md +ObsidianToday" \
  docs="cd ${HOME}/Documents/zettelkasten && ${EDITOR} ." \
  cf="cd ${HOME}/.config" \
  repo="cd ${HOME}/source/repos"

# Shows git branch on shell prompt
source /usr/share/git/completion/git-prompt.sh
PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '

# Automatically start tmux if not already inside tmux
# Only auto-start in terminal emulators (pts), not on login TTY
if [ -z "$TMUX" ] && [[ $(tty) == /dev/pts/* ]]; then
  exec tmux
fi
