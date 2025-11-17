# Homebrew
[[ "$(uname)" == "Darwin" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Colors
autoload -U colors && colors

# Terminal config
stty stop undef   # Disable ctrl-s to freeze terminal.

# History in cache directory:
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.cache/zsh_history
setopt INC_APPEND_HISTORY
export HISTTIMEFORMAT="[%F %T] "
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS

# Load aliases and binds if existent.
if [[ "$(uname)" == "Darwin" ]]; then
    [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/darwin_aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/darwin_aliasrc"
else
    [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/bindrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/bindrc"
    [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliasrc"
fi

# PATH
export HSA_OVERRIDE_GFX_VERSION=10.3.0
export PATH=$PATH:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.emacs.d/bin
export EDITOR="vim"
export GOPATH=$HOME/go

# Autocomplete
autoload -Uz compinit
compinit
_comp_options+=(globdots)   # Include hidden files.

# GPG for SSH
if [[ "$(uname)" == "Darwin" ]]; then
    export GPG_TTY=$(tty)
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    gpgconf --launch gpg-agent
else
    unset SSH_AGENT_PID
    if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    gpgconf --launch gpg-agent
    fi
fi

# Plugins
source ~/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source ~/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

export XCURSOR_SIZE=24

# Starship
eval "$(starship init zsh)"
