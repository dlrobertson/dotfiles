# This will set the default prompt to the walters theme
alias ls="ls -G"
alias ed="ed -p ': p:'"

export GPG_TTY=$(tty)

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}

export CCACHE_COMPRESS=1
export CCACHE_CPP2=1
export TERMINAL=alacritty

if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
else
    # Load version control information
    autoload -Uz vcs_info
    precmd() { vcs_info }

    # Format the vcs_info_msg_0_ variable
    zstyle ':vcs_info:git:*' formats 'on branch %b'

    # Set up the prompt (with git branch name)
    setopt PROMPT_SUBST
    PROMPT='%n in ${PWD/#$HOME/~} ${vcs_info_msg_0_} % '
fi

bindkey -v
export TERM=xterm-256color

if [ -f $HOME/.zsh_profile ]; then
    source $HOME/.zsh_profile
fi
