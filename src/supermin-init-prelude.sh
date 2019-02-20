#!/usr/bin/env bash
mount -t proc /proc /proc
mount -t sysfs /sys /sys
mount -t devtmpfs devtmpfs /dev

# load selinux policy
#LANG=C /sbin/load_policy  -i

# load kernel module for 9pnet_virtio for 9pfs mount
/sbin/modprobe 9pnet_virtio

# need fuse module for rofiles-fuse/bwrap during post scripts run
/sbin/modprobe fuse

# set up networking
/usr/sbin/dhclient eth0

# set up workdir
mkdir -p "/host/${workdir:?}"
mount -t 9p -o rw,trans=virtio,version=9p2000.L host /host
mount -t 9p -o rw,trans=virtio,version=9p2000.L workdir "/host/${workdir}"

mount -t tmpfs none /host/tmp

mount -t proc /proc /host/proc
mount -t sysfs /sys /host/sys
mount -t devtmpfs devtmpfs /host/dev

if [ -L "/host/${workdir}"/src/config ]; then
    mkdir -p "$(readlink "/host/${workdir}"/src/config)"
    mount -t 9p -o rw,trans=virtio,version=9p2000.L source "/host/${workdir}"/src/config
fi
mkdir -p "/host/${workdir}"/cache "/host/${workdir}"/cache/container-tmp
mount /dev/sdb1 "/host/${workdir}"/cache

# https://github.com/koalaman/shellcheck/wiki/SC2164
#cd "${workdir}" || exit
