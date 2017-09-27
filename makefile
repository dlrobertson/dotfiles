DEST ?= $(HOME)
LOCAL_BIN ?= $(DEST)/.local/bin
XDG_CONFIG_HOME := $(DEST)/.config

VIM ?= nvim
ifeq ($(VIM), nvim)
	VIMDIR := $(XDG_CONFIG_HOME)/nvim
	NEOBUNDLE := $(VIMDIR)/bundle/neobundle.vim
	VIMRC := $(VIMDIR)/init.vim
else ifeq ($(VIM), vim)
	VIMDIR := $(DEST)/.vim
	NEOBUNDLE := $(VIMDIR)/bundle/neobundle.vim
	VIMRC := $(DEST)/.vimrc
else
	echo "Do not know how to install for $(VIM)"
	exit 1
endif

SWAYDIR ?= $(XDG_CONFIG_HOME)/sway

HELPERS := $(addprefix $(LOCAL_BIN)/, rfc vmiplist)

GENERICRCS := \
	.bashrc .tmux.conf .i3 .gitconfig .gitignore .gdbinit .lldbinit .lldb_utils.py \
	.xinitrc .muttrc .Xresources .radare2rc .git-prompt.sh

DOTFILES := $(VIMRC) $(SWAYDIR) $(addprefix $(DEST)/, $(GENERICRCS))

all: dirs $(DOTFILES) $(HELPERS)

dirs: $(DEST) $(XDG_CONFIG_HOME) $(VIMDIR) $(NEOBUNDLE) $(LOCAL_BIN)

$(DEST):
	mkdir -p $(DEST)

$(XDG_CONFIG_HOME):
	mkdir -p $(XDG_CONFIG_HOME)

$(VIMDIR):
	mkdir -p $(VIMDIR)

$(DEST)/.git-prompt.sh:
	curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > $(DEST)/.git-prompt.sh

$(NEOBUNDLE):
	git clone https://github.com/Shougo/neobundle.vim $@

$(VIMRC): $(PWD)/myvimrc
	ln -svf $< $@
	$(VIM) +NeoBundleInstall +qall

$(XDG_CONFIG_HOME)/%: $(PWD)/%
	ln -svf $< $@

$(DEST)/.%: $(PWD)/%
	ln -svf $< $@

$(DEST)/.gitignore:
	printf "*~\n*.sw[op]\nbuild/\n" > $@

$(DEST)/.%: $(PWD)/templates/% $(DEST)/.bash_profile
	bash --login -c envsubst < $< | cat > $@

$(LOCAL_BIN):
	mkdir -p $(LOCAL_BIN)
	mkdir -p $(DEST)/.local/share/rfcs

$(LOCAL_BIN)/%: $(PWD)/scripts/%
	ln -svf $< $@

clean:
	rm -rf $(DOTFILES) $(HELPERS) $(VIMDIR)
