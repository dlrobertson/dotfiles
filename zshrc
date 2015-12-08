# Lines configured by zsh-newuser-install
source ~/.zprofile

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
# End of lines configured by zsh-newuser-install
autoload -U compinit promptinit
compinit
promptinit

# This will set the default prompt to the walters theme
alias ls="ls --color=auto"
alias -s html=google-chrome-stable
alias ed="ed -p:"

export SPARK_HOME=/home/drobertson/git/spark

# set up path for spark and go
export PATH=${PATH}:${HOME}/dev/go/bin:${SPARK_HOME}/bin

#export HADOOP_HOME=/usr/local/hadoop
#export JAVA_HOME=/usr/lib/jvm/java-8-openjdk
#export PATH=$PATH:/usr/local/bin/:$HADOOP_HOME/bin

export CPATH=${HOME}/.local/include
export LD_LIBRARY_PATH=/usr/lib:/usr/lib64:${LD_LIBRARY_PATH}:/usr/local/lib
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}

export GOPATH=$HOME/dev/go
export LFS=/mnt/lfs
export EDITOR=/usr/bin/vim
export CCACHE_COMPRESS=1
export CCACHE_CPP2=1
export TERMINAL=st
export CC=clang
export CXX=clang++

export WLD=$HOME/.local
export LD_LIBRARY_PATH=$WLD/lib
export PKG_CONFIG_PATH=$WLD/lib/pkgconfig/:$WLD/share/pkgconfig/
export PATH=$WLD/bin:$PATH

setopt promptsubst
autoload -U colors && colors # Enable colors in prompt

source ~/.git-prompt.sh

GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUPSTREAM="verbose"
GIT_PS1_SHOWCOLORHINTS=true

# Set the right-hand prompt
RPROMPT='%F{blue}%~%f'
precmd () { __git_ps1 "%(?..[%i])%F{6}%U%n%u%f%F{1}@%M%f " $'\n%f%(?.%F{green}.%F{red})\u279c  %f' "%s" }
