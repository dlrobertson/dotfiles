#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mount.h>

#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#include <errno.h>

#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>

#include <init.h>

static char* const s_busybox_args[] = {RESCUE_SHELL, "sh", NULL};
static char* const s_init_args[] = {INIT_BIN, NULL};

#define TRY_MOUNT(src, dst, fs, flags, data) \
    if(mount(src, dst, fs, flags, data) != 0) { \
        fprintf(stderr, "ERROR: mount(%s, %s, %s, %d, %s) failed errno=%s\n", \
                src ? src : "NULL", dst ? dst : "NULL", fs ? fs : "NULL", flags, \
                (data) ? (const char*)data : "NULL", strerror(errno)); \
        execve(RESCUE_SHELL, s_busybox_args, envp); \
    }

#define TRY_UMOUNT(dst) \
    if(umount(dst) != 0) { \
        fprintf(stderr, "ERROR: umount(%s) failed errno=%s\n", \
                dst ? dst : "NULL", strerror(errno)); \
        execve(RESCUE_SHELL, s_busybox_args, envp); \
    }

bool not_dot(const char* dirname) {
    if(strlen(dirname) == 1 && strncmp(dirname, ".", 1) == 0) {
        return false;
    } else if(strlen(dirname) == 2 && strncmp(dirname, "..", 2) == 0) {
        return false;
    } else {
        return true;
    }
}

void delete_all_of_device(const char* src, dev_t rootdev) {
    size_t newdir_size = 0;
    DIR* dir;
    struct dirent* d;
    struct stat st;
    char* newdir;
    const char* aIter;
    const char* aEnd;
    char* bIter;

    if(lstat(src, &st) || st.st_dev != rootdev) {
        return;
    }

    if(S_ISDIR(st.st_mode)) {
        dir = opendir(src);
        if(dir) {
            while((d = readdir(dir))) {
                if(not_dot(d->d_name)) {
                    newdir_size = strlen(d->d_name) + 2 + strlen(src);
                    newdir = malloc(newdir_size);
                    bzero(newdir, newdir_size);
                    bIter = newdir;
                    aEnd = src + strlen(src);
                    for(aIter = src; aIter != aEnd; ++aIter, ++bIter) {
                        *bIter = *aIter;
                    }
                    if(newdir[strlen(newdir) - 1] != '/') {
                    	*(bIter) = '/';
                        ++bIter;
                    }
                    aEnd = d->d_name + strlen(d->d_name);
                    for(aIter = d->d_name; aIter != aEnd; ++aIter, ++bIter) {
                        *bIter = *aIter;
                    }
                    delete_all_of_device(newdir, rootdev);
                    free(newdir);
                }
            }
            closedir(dir);
            rmdir(src);
        }
    } else {
        unlink(src);
    }
}

int main(int argc, char** argv, char** envp) {
    // needed vars
    struct stat st;
    dev_t rootdev;
    int local_err;

    // mount necessary fs
    TRY_MOUNT("proc", "/proc", "proc", 0, NULL);
    TRY_MOUNT("sysfs", "/sys", "sysfs", 0, NULL);
    TRY_MOUNT("devtmpfs", "/dev", "devtmpfs", 0, NULL);

    // sleep while we wait for /dev to be populated
    sleep(3);

    // mount the root
    if(mount(ROOT_DEV, NEWROOT, "btrfs", 0, ROOT_MOUNT_OPTS) != 0) {
        local_err = errno;
#ifdef BTRFS_RAID1
        TRY_MOUNT(RAID1_MIRROR, NEWROOT, "btrfs", 0, ROOT_MOUNT_OPTS);
#ifdef MOUNT_USR
        TRY_MOUNT(RAID1_MIRROR, USR_NEWROOT, "btrfs", 0, USR_MOUNT_OPTS);
#endif // MOUNT_USR
#else
        fprintf(stderr, "ERROR: mount(%s, %s, %s, %d, %s) failed errno=%s\n",
                ROOT_DEV, NEWROOT, "btrfs", 0, ROOT_MOUNT_OPTS, strerror(local_err));
        execve(RESCUE_SHELL, s_busybox_args, envp);
#endif // BTRFS_RAID1
    } else {
#ifdef MOUNT_USR
        TRY_MOUNT(ROOT_DEV, USR_NEWROOT, "btrfs", 0, USR_MOUNT_OPTS);
#endif // MOUNT_USR
    }

    // unmount mountpoints other than root
    TRY_UMOUNT("/proc");
    TRY_UMOUNT("/sys");
    TRY_UMOUNT("/dev");

    // chdir to root and run some sanity checks
    chdir(NEWROOT);
    stat("/", &st);
    rootdev = st.st_dev;
    stat(".", &st);
    if(st.st_dev == rootdev || getpid() != 1) {
        fprintf(stderr, "ERROR: rootdev is %s pid=%d\n", NEWROOT, getpid());
        execve(RESCUE_SHELL, s_busybox_args, envp);
    }
    if(stat("/init", &st) != 0 || !S_ISREG(st.st_mode)) {
        fprintf(stderr, "ERROR: /init is not a file\n");
        execve(RESCUE_SHELL, s_busybox_args, envp);
    }

    // delete everything on root device
    delete_all_of_device("/", rootdev);

    // chroot and exec INIT_BIN
    TRY_MOUNT(".", "/", NULL, MS_MOVE, NULL);
    chroot(".");
    execv(INIT_BIN, s_init_args);

    // rescue shell if init did not work
    fprintf(stderr, "ERROR: execv(%s, s_init_args) did not work", INIT_BIN);
    execve(RESCUE_SHELL, s_busybox_args, envp);
}
