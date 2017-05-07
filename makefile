DEST ?= $(HOME)
LOCAL_BIN ?= $(DEST)/.local/bin
XDG_CONFIG_HOME ?= $(DEST)/.config
VIM_DIR ?= $(DEST)/.vim
NVIM_DIR ?= $(XDG_CONFIG_HOME)/nvim

HELPERS := $(LOCAL_BIN)/rfc

RCFILES := $(DEST)/.bashrc $(DEST)/.tmux.conf $(DEST)/.i3 $(DEST)/.gitconfig \
	$(DEST)/.gitignore $(DEST)/.gdbinit $(DEST)/.lldbinit $(DEST)/.lldb_utils.py \
	$(DEST)/.xinitrc $(DEST)/.muttrc $(DEST)/.Xresources

all: nvim $(RCFILES) $(HELPERS)

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

$(DEST)/.%: $(PWD)/%
	ln -svf $< $@

$(DEST)/.gitignore:
	printf "*~\n*.sw[op]\nbuild/\n" > $@

clean:
	rm -rf $(RCFILES) $(HELPERS) $(NVIM_DIR)

$(LOCAL_BIN)/%: $(PWD)/scripts/%
	ln -svf $< $@
