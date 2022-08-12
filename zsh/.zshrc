# Colors
autoload -U colors && colors

# Terminal config
stty stop undef   # Disable ctrl-s to freeze terminal.

# History in cache directory:
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.cache/zsh/history

# Load aliases and binds if existent.
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/bindrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/bindrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/spaceshiprc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/spaceshiprc"

# PATH
export PATH=$PATH:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.emacs.d/bin
export EDITOR="vim"

# Autocomplete
autoload -Uz compinit
compinit
_comp_options+=(globdots)   # Include hidden files.

# Spaceship
autoload -U promptinit; promptinit
prompt spaceship

# gitlab.com/dwt1/shell-color-scripts
# sh-colorscript random

# GPG for SSH
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi


# Plugins
source ~/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source ~/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source ~/.config/zsh/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Spark
sleep 0.03; echo; echo; seq 1 $COLUMNS | sort -R | spark | lolcat; echo; echo;
