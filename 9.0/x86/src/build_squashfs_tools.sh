#!/bin/sh
# $1 parameter is the TinyCore Linux major version
# $2 parameter is the TinyCore Linux architecture
set -e

apk add --no-cache curl squashfs-tools >/dev/null

if [ ! -f squashfs-tools.tcz ]; then
    curl -SLO http://tinycorelinux.net/$1.x/$2/tcz/squashfs-tools.tcz >/dev/null
fi

[ -d /mnt ] || mkdir /mnt
unsquashfs -f -d /mnt squashfs-tools.tcz >/dev/null
tar cf - -C /mnt . | gzip -c
