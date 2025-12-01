#
# ${ZDOTDIR}/.zshrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# -----------------------------------------------------------------------------
# History
# -----------------------------------------------------------------------------
export HISTFILE="$ZDOTDIR/.zhistory"
export HISTSIZE=10000
export SAVEHIST=10000

setopt HIST_SAVE_NO_DUPS       # Don't save duplicate commands
setopt HIST_IGNORE_ALL_DUPS    # Remove older duplicate from history
setopt HIST_FIND_NO_DUPS       # Don't show duplicates when searching
setopt SHARE_HISTORY           # Share history between sessions

# -----------------------------------------------------------------------------
# Directory Navigation
# -----------------------------------------------------------------------------
setopt AUTO_PUSHD              # Push directories onto stack
setopt PUSHD_IGNORE_DUPS       # No duplicates in stack
setopt PUSHD_SILENT            # Don't print stack after pushd/popd

# -----------------------------------------------------------------------------
# Completion
# -----------------------------------------------------------------------------
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select                    # Menu selection
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'   # Case insensitive
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # Colored completions

# -----------------------------------------------------------------------------
# Vim Mode
# -----------------------------------------------------------------------------
bindkey -v
export KEYTIMEOUT=1

# Cursor shape for different vim modes
function zle-keymap-select {
    case $KEYMAP in
        vicmd) echo -ne '\e[2 q';;      # Block cursor for normal mode
        viins|main) echo -ne '\e[6 q';; # Beam cursor for insert mode
    esac
}
zle -N zle-keymap-select

# Set beam cursor on startup and for each new prompt
function zle-line-init {
    echo -ne '\e[6 q'
}
zle -N zle-line-init

# Better vim keybindings
bindkey '^?' backward-delete-char  # Backspace works in insert mode
bindkey '^w' backward-kill-word    # Ctrl+w deletes word
bindkey '^u' backward-kill-line    # Ctrl+u deletes to start of line

# -----------------------------------------------------------------------------
# Prompt with Git Status
# -----------------------------------------------------------------------------
autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' (%b%u%c)'
zstyle ':vcs_info:git:*' actionformats ' (%b|%a%u%c)'
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' stagedstr '+'

setopt PROMPT_SUBST
PROMPT='%B%F{cyan}%1~%f%b%F{magenta}${vcs_info_msg_0_}%f %F{green}$%f '
# -----------------------------------------------------------------------------
# Plugins (clone manually to ~/.local/share/zsh/plugins/)
# -----------------------------------------------------------------------------
PLUGIN_DIR="$HOME/.local/share/zsh/plugins"

# zsh-autosuggestions
[[ -f "$PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "$PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"

# zsh-syntax-highlighting (must be last)
[[ -f "$PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
    source "$PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------

# General
alias \
    cls='clear && eza -1A' \
    eza="eza -A1" \
    exmon='wlr-randr --output eDP-1 --off' \
    grep='grep --color=auto' \
    ls='ls --color=auto' \
    lg='lazygit' \
    sourcez="source ${ZDOTDIR}/.zshrc" \
    wttr="curl wttr.in" \
    v="nvim" \
    vim="nvim" \
    obsidian="obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland" \
    calcurse="calcurse -D ${HOME}/Documents/calcurse" \
    fd="fd -IH" \
    rg="rg -IH" \
    wcp="wl-copy" \
    rsync="rsync -av --info=progress2" \
    suspend="systemctl suspend"

# Shortcuts
alias \
    ric="cd ${HOME}/Documents/ricardo && \${EDITOR} vault-root.md +ObsidianToday" \
    ether="cd ${HOME}/Documents/mai/ether && \${EDITOR} ether\ \(todos\).md" \
    bys="cd ${HOME}/Documents/bys && \${EDITOR} ." \
    docs="cd ${HOME}/Documents/zettelkasten && \${EDITOR} ." \
    cf="cd ${HOME}/.config" \
    cfz="\$EDITOR ${ZDOTDIR}/.zshrc" \
    cfb="\$EDITOR ${HOME}/.bashrc" \
    repo="cd ${HOME}/source/repos" \
    rice="cd ${HOME}/.local/share/ricing"

# -----------------------------------------------------------------------------
# mupdf wrapper with automatic XWayland management
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# Tmux auto-start
# -----------------------------------------------------------------------------
# Only auto-start in terminal emulators (pts), not on login TTY
if [ -z "$TMUX" ] && [[ $(tty) == /dev/pts/* ]]; then
    exec tmux
fi
