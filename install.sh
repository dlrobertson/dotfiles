#!/bin/bash

install_file () {
    ln -svf $PWD/$1 $HOME/.$1
}

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
mkdir ~/.yankring
install_file vimrc
vim +PluginInstall +qall
install_file tmux.conf
install_file bashrc
install_file i3
install_file gitconfig
cat > ~/.gitignore << EOF
*~
*.sw[op]
EOF
install_file gdbinit
install_file lldbinit
install_file lldb_utils.py
