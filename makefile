DEST ?= $(HOME)
LOCAL_BIN ?= $(DEST)/.local/bin
XDG_CONFIG_HOME := $(DEST)/.config

VIM ?= nvim
ifeq ($(VIM), nvim)
	VIMDIR := $(XDG_CONFIG_HOME)/nvim
	VIMRC := $(VIMDIR)/init.vim
	VIMAUTOLOAD := $(HOME)/.local/share/nvim/site/autoload
	VIMPLUGINDIR := $(HOME)/.local/share/nvim/plugged
else ifeq ($(VIM), vim)
	VIMDIR := $(DEST)/.vim
	VIMRC := $(DEST)/.vimrc
	VIMAUTOLOAD := $(VIMDIR)/autoload
	VIMPLUGINDIR := $(HOME)/.vim/plugged
else
	echo "Do not know how to install for $(VIM)"
	exit 1
endif

XDGCONFDIRS ?= sway ion alacritty tridactyl starship.toml

XDGCONF := $(addprefix $(XDG_CONFIG_HOME)/, $(XDGCONFDIRS))

HELPERS := $(addprefix $(LOCAL_BIN)/, rfc)

GENERICRCS := \
	.bashrc .tmux.conf .i3 .gitconfig .gitignore .gdbinit \
	.xinitrc .muttrc .Xresources .radare2rc .git-prompt.sh

DOTFILES := $(VIMRC) $(XDGCONF) $(addprefix $(DEST)/, $(GENERICRCS))

all: dirs $(DOTFILES) $(HELPERS)

dirs: $(DEST) $(XDG_CONFIG_HOME) $(VIMDIR) $(VIMAUTOLOAD)/plug.vim $(LOCAL_BIN)

$(DEST):
	@mkdir -p $(DEST)

$(XDG_CONFIG_HOME):
	@mkdir -p $(XDG_CONFIG_HOME)

$(VIMDIR):
	@mkdir -p $(VIMDIR)

$(DEST)/.git-prompt.sh:
ifeq ($(wildcard /usr/share/git/git-prompt.sh),)
	@curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > $(DEST)/.git-prompt.sh
else
	@ln -svf /usr/share/git/git-prompt.sh $@
endif

$(VIMAUTOLOAD):
	mkdir -p $@

$(VIMAUTOLOAD)/plug.vim: $(VIMAUTOLOAD)
	@curl -fLo $@ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

$(VIMRC): $(PWD)/myvimrc
	@ln -svf $< $@
	@$(VIM) +PlugInstall +qall

$(XDG_CONFIG_HOME)/%: $(PWD)/xdg/%
	@ln -svf $< $@

$(DEST)/.%: $(PWD)/%
	@ln -svf $< $@

$(DEST)/.gitignore:
	@printf "*~\n*.sw[op]\nbuild/\n.vimrc\n.nvimrc\n" > $@

$(DEST)/.%: $(PWD)/templates/% $(DEST)/.bash_profile $(PWD)/templates/%.tail
	@cp -v $< $@
	@sed -ie 's/@@GIT_EMAIL@@/$(GIT_EMAIL)/' $@
	@sed -ie 's/@@SIGNKEY@@/$(SIGNKEY)/' $@
	@cat $<.tail >> $@

$(DEST)/.%: $(PWD)/templates/% $(DEST)/.bash_profile
	@cp -v $< $@
	@sed -ie 's/@@GIT_EMAIL@@/$(GIT_EMAIL)/' $@
	@sed -ie 's/@@SIGNKEY@@/$(SIGNKEY)/' $@

$(LOCAL_BIN):
	@mkdir -p $(LOCAL_BIN)
	@mkdir -p $(DEST)/.local/share/rfcs

$(LOCAL_BIN)/%: $(PWD)/scripts/%
	@ln -svf $< $@

clean:
	@rm -rf $(DOTFILES) $(HELPERS) $(VIMDIR) $(VIMAUTOLOAD) $(VIMPLUGINDIR) $(XDGCONF)
