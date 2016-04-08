cur_wd=$(pwd)
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
mkdir ~/.yankring
ln -svf ${cur_wd}/vimrc $HOME/.vimrc
vim +PluginInstall +qall
ln -svf ${cur_wd}/xinitrc $HOME/.xinitrc
ln -svf ${cur_wd}/Xmodmap $HOME/.Xmodmap
ln -svf ${cur_wd}/muttrc $HOME/.muttrc
ln -svf ${cur_wd}/tmux $HOME/.tmux
ln -svf ${cur_wd}/tmux.conf $HOME/.tmux.conf
ln -svf ${cur_wd}/bashrc $HOME/.bashrc
ln -svf ${cur_wd}/i3 $HOME/.i3
