HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# This will set the default prompt to the walters theme
alias ls="ls -G"
alias ed="ed -p ': p:'"

export GPG_TTY=$(tty)

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}

export CCACHE_COMPRESS=1
export CCACHE_CPP2=1
export TERMINAL=alacritty

if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
elif [ -f $HOME/.git-prompt.sh ]; then
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_SHOWSTASHSTATE=1
    GIT_PS1_SHOWUPSTREAM=verbose
    GIT_PS1_DESCRIBE_STYLE=default
    GIT_PS1_SHOWCOLORHINTS=1

    source ~/.git-prompt.sh

    PROMPT_COMMAND='__git_ps1 "\e[36m\u\e[0m\e[31m@\h\e[0m: \e[93m\w\e[0m" "\n⇒ "'
fi

set -o vi
export TERM=xterm-256color
