cur_wd=$(pwd)
ln -svf ${cur_wd}/vimrc $HOME/.vimrc
vim +PluginInstall +qall
ln -svf ${cur_wd}/xinitrc $HOME/.xinitrc
ln -svf ${cur_wd}/Xmodmap $HOME/.Xmodmap
if [ hash mutt 2> /dev/null ]; then
    ln -svf ${cur_wd}/muttrc $HOME/.muttrc
fi
if [ hash tmux 2> /dev/null ]; then
    ln -svf ${cur_wd}/tmux $HOME/.tmux
    ln -svf ${cur_wd}/tmux.conf $HOME/.tmux.conf
fi
if [ hash zsh 2> /dev/null ]; then
    ln -svf ${cur_wd}/zshrc $HOME/.zshrc
fi
