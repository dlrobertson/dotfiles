DEST ?= $(HOME)
XDG_CONFIG_HOME ?= $(DEST)/.config
VIM_DIR ?= $(DEST)/.vim
NVIM_DIR ?= $(XDG_CONFIG_HOME)/nvim

all: $(DEST)/.bashrc nvim $(DEST)/.tmux.conf $(DEST)/.i3 $(DEST)/.gitconfig \
	$(DEST)/.gitignore $(DEST)/.gdbinit $(DEST)/.lldbinit $(DEST)/.lldb_utils.py \
	$(DEST)/.xinitrc $(DEST)/.muttrc $(DEST)/.Xresources

$(DEST)/.bashrc: $(PWD)/bashrc
	ln -svf $< $@
	curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > $(DEST)/.git-prompt.sh

$(DEST)/.vimrc: $(PWD)/vimrc
	ln -svf $< $@

nvim: $(NVIM_DIR) $(NVIM_DIR)/bundle/Vundle.vim $(NVIM_DIR)/init.vim

$(NVIM_DIR)/bundle/Vundle.vim:
	git clone https://github.com/VundleVim/Vundle.vim.git $(NVIM_DIR)/bundle/Vundle.vim

$(NVIM_DIR):
	mkdir -p $(NVIM_DIR)

$(NVIM_DIR)/init.vim: $(PWD)/vimrc
	ln -svf $< $@
	nvim +PluginInstall +qall

$(DEST)/.tmux.conf: $(PWD)/tmux.conf
	ln -svf $< $@

$(DEST)/.i3: $(PWD)/i3
	ln -svf $< $@

$(DEST)/.gitconfig: $(PWD)/gitconfig
	ln -svf $< $@

$(DEST)/.gitignore:
	printf "*~\n*.sw[op]\nbuild/\n" > $@

$(DEST)/.gdbinit: $(PWD)/gdbinit
	ln -svf $< $@

$(DEST)/.lldbinit: $(PWD)/lldbinit
	ln -svf $< $@

$(DEST)/.lldb_utils.py: $(PWD)/lldb_utils.py
	ln -svf $< $@

$(DEST)/.xinitrc: $(PWD)/xinitrc
	ln -svf $< $@
	
$(DEST)/.muttrc: $(PWD)/muttrc
	ln -svf $< $@

$(DEST)/.Xresources: $(PWD)/Xresources
	ln -svf $< $@

clean:
	rm -rf $(DEST)/.bashrc $(NVIM_DIR) $(DEST)/.tmux.conf $(DEST)/.i3 $(DEST)/.gitconfig \
	$(DEST)/.gitignore $(DEST)/.gdbinit $(DEST)/.lldbinit $(DEST)/.lldb_utils.py \
	$(DEST)/.xinitrc $(DEST)/.muttrc $(DEST)/.Xresources $(DEST)/.git-prompt.sh
