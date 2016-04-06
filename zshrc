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
alias ed="ed -p ': p:'"

export SPARK_HOME=/home/drobertson/git/spark

# set up path for spark and go
#export PATH=${PATH}:${HOME}/dev/go/bin:${SPARK_HOME}/bin
#export PATH="$(ruby -e 'print Gem.user_dir')/bin:$HOME/.cargo/bin:$PATH"

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
export CC=gcc
export CXX=g++

setopt prompt_subst
autoload -U colors && colors # Enable colors in prompt

# Modify the colors and symbols in these variables as desired.
GIT_PROMPT_PREFIX="%{$fg[green]%}[%{$reset_color%}"
GIT_PROMPT_SUFFIX="%{$fg[green]%}]%{$reset_color%}"
GIT_PROMPT_AHEAD="%{$fg[red]%}NUM\u21e8 %{$reset_color%}"
GIT_PROMPT_BEHIND="%{$fg[cyan]%}\u21e6 NUM%{$reset_color%}"
GIT_PROMPT_MERGING="%{$fg_bold[magenta]%}\u2639 %{$reset_color%}"
GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}\u2623 %{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$fg[yellow]%}\u2387 %{$reset_color%}"
GIT_PROMPT_STAGED="%{$fg[green]%}\u2615 %{$reset_color%}"

# Show Git branch/tag, or name-rev if on detached head
parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

# Show different symbols as appropriate for various Git repository states
parse_git_state() {

  # Compose this value via multiple conditional appends.
  local GIT_STATE=""

  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi

  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
  fi

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_UNTRACKED
  fi

  if ! git diff --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
  fi

  if [[ -n $GIT_STATE ]]; then
    echo "$GIT_PROMPT_PREFIX$GIT_STATE$GIT_PROMPT_SUFFIX"
  fi

}

# If inside a Git repository, print its branch and state
git_prompt_string() {
  local git_where="$(parse_git_branch)"
  [ -n "$git_where" ] && echo "$(parse_git_state)$GIT_PROMPT_PREFIX%{$fg[yellow]%}${git_where#(refs/heads/|tags/)}$GIT_PROMPT_SUFFIX"
}

PS1="%(?..[%i])%F{6}%U%n%u%f%F{1}@%M%f"
PS1="$PS1 "$'$(git_prompt_string)\n%(?.%F{green}.%F{red})\u279c  %f'
RPROMPT="%F{green}%~%f"

export PATH="$HOME/.cargo/bin:$PATH"
