WDIR ?= /usr/src/initramfs
BUILD := ./build

NEEDED_DIRS := bin \
	dev \
	etc \
	etc/udev \
	lib \
	lib64 \
	mnt \
	mnt/root \
	proc \
	root \
	sbin \
	sys

BUSYBOX := /bin/busybox

DIRS := $(addprefix $(BUILD)/, $(NEEDED_DIRS))

DEVS := $(addprefix $(WDIR)/dev/, null tty console)

UDEV_CONF := $(BUILD)/etc/udev/udev.conf

UDEV_RULES := $(BUILD)/etc/udev/rules.d

all: $(DIRS) $(UDEV_CONF) $(UDEV_RULES) $(BUILD)$(BUSYBOX) $(BUILD)/init

$(BUILD):
	mkdir -p $(BUILD)

$(UDEV_CONF):
	cp -a /etc/udev/udev.conf $(BUILD)/etc/udev/udev.conf

$(UDEV_RULES):
	cp -ar /etc/udev/rules.d $(BUILD)/etc/udev/rules.d

$(BUILD)$(BUSYBOX):
	cp -a $(BUSYBOX) $(BUILD)$(BUSYBOX)

$(WDIR)/dev/null:
	mknod -m 666 $(WDIR)/dev/null c 1 3

$(WDIR)/dev/tty:
	mknod -m 666 $(WDIR)/dev/tty c 5 0

$(WDIR)/dev/console:
	mknod -m 640 $(WDIR)/dev/console c 5 1

$(DIRS):
	mkdir -p $(DIRS)

$(BUILD)/init:
	$(CC) -std=c99 -static -o $(BUILD)/init ./init.c

clean:
	rm -rf $(BUILD)

clean_initramfs:
	rm -rf $(WDIR)

create_initramfs:
	cp -r $(BUILD) $(WDIR)

install: clean_initramfs create_initramfs $(DEVS)
