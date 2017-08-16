DEST ?= $(HOME)
LOCAL_BIN ?= $(DEST)/.local/bin
XDG_CONFIG_HOME ?= $(DEST)/.config
VIM_DIR ?= $(DEST)/.vim
NVIM_DIR ?= $(XDG_CONFIG_HOME)/nvim
NVIM ?= $(shell which nvim 2> /dev/null)
SWAY_DIR ?= $(XDG_CONFIG_HOME)/sway

HELPERS := $(addprefix $(LOCAL_BIN)/, rfc vmiplist)

RCFILES := $(DEST)/.bashrc $(DEST)/.tmux.conf $(DEST)/.i3 $(DEST)/.gitconfig \
	$(DEST)/.gitignore $(DEST)/.gdbinit $(DEST)/.lldbinit $(DEST)/.lldb_utils.py \
	$(DEST)/.xinitrc $(DEST)/.muttrc $(DEST)/.Xresources $(SWAY_DIR)

all: nvim sway $(RCFILES) $(LOCAL_BIN) $(HELPERS)

$(DEST)/.bashrc: $(PWD)/bashrc
	ln -svf $< $@
	curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > $(DEST)/.git-prompt.sh

$(DEST)/.vimrc: $(PWD)/vimrc
	ln -svf $< $@

nvim: nvim_check $(NVIM_DIR) $(NVIM_DIR)/bundle/Vundle.vim $(NVIM_DIR)/init.vim

nvim_check:
ifeq ($(NVIM),)
	@echo "Must install neovim before continuing"
	@exit 1
endif

$(NVIM_DIR)/bundle/Vundle.vim:
	git clone https://github.com/VundleVim/Vundle.vim.git $(NVIM_DIR)/bundle/Vundle.vim

$(NVIM_DIR):
	mkdir -p $(NVIM_DIR)

$(NVIM_DIR)/init.vim: $(PWD)/vimrc
	ln -svf $< $@
	$(NVIM) +PluginInstall +qall

$(DEST)/.config/%: $(PWD)/%
	ln -svf $< $@

$(DEST)/.%: $(PWD)/%
	ln -svf $< $@

$(DEST)/.gitignore:
	printf "*~\n*.sw[op]\nbuild/\n" > $@

$(DEST)/.%: $(PWD)/templates/% $(DEST)/.bashrc $(DEST)/.bash_profile
	bash --login -c envsubst < $< | cat > $@

$(LOCAL_BIN):
	mkdir -p $(LOCAL_BIN)
	mkdir -p $(DEST)/.local/share/rfcs

$(LOCAL_BIN)/%: $(PWD)/scripts/%
	ln -svf $< $@

clean:
	rm -rf $(RCFILES) $(HELPERS) $(NVIM_DIR)
