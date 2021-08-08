#!/bin/bash

mkdir -pv dev sys
mount -t tmpfs -o nosuid tmpfs dev
mkdir -pv dev/shm dev/pts
mount -t tmpfs -o nosuid,nodev shm "dev/shm"
mount -t devpts -o nosuid,noexec,gid=5,mode=620,ptmxmode=666,newinstance devpts "dev/pts"
ln -snf pts/ptmx "dev/ptmx"
ln -snf /proc/self/fd "dev/fd"
ln -snf /proc/self/fd/0 "dev/stdin"
ln -snf /proc/self/fd/1 "dev/stdout"
ln -snf /proc/self/fd/2 "dev/stderr"
mknod "dev/null" c 1 3
mknod "dev/zero" c 1 5
mknod "dev/random" c 1 8
mknod "dev/urandom" c 1 9
mknod "dev/console" c 5 1
mknod "dev/tty" c 5 0
chmod 666 "dev/null" "dev/zero" "dev/random" "dev/urandom" "dev/tty"
chmod 600 "dev/console"
mount -t sysfs sysfs "sys"
mount -t proc proc proc

cmd="chroot . /bin/bash"

linux64 env - unshare -mpf /bin/sh -c "$cmd"