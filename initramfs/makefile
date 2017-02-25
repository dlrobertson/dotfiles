WDIR ?= ./initramfs

NEEDED_DIRS := bin \
	dev \
	etc \
	lib \
	lib64 \
	mnt \
	mnt/root \
	proc \
	root \
	sbin \
	sys

DIRS := $(addprefix $(WDIR)/, $(NEEDED_DIRS))

DEVS := $(addprefix $(WDIR)/dev/, null tty console)

all: $(WDIR)/init

$(WDIR):
	mkdir -p $(WDIR)

$(WDIR)/dev/null:
	mknod -m 666 $(WDIR)/dev/null c 1 3

$(WDIR)/dev/tty:
	mknod -m 666 $(WDIR)/dev/tty c 5 0

$(WDIR)/dev/console:
	mknod -m 640 $(WDIR)/dev/console c 5 1

$(DIRS):
	mkdir -p $(DIRS)

$(WDIR)/init: $(WDIR) $(DIRS) $(DEVS)
	$(CC) -std=c99 -static -o ./$(WDIR)/init ./init.c

clean:
	rm -rf $(WDIR)
