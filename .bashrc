#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias lg='lazygit'
alias exmon='wlr-randr --output eDP-1 --off'
alias grep='grep --color=auto'
alias cls='clear && exa -1A'
PS1='[\u@\h \W]\$ '
