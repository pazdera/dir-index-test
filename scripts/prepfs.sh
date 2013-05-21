#!/bin/bash

FS="$1"
DEVICE="$2"
RESULTS_DIR="$3"

umount "$DEVICE" >/dev/null 2>/dev/null
echo "Creating $FS file system on $DEVICE"
case $FS in
    "ext4"|"ext4-spd"|"ext4-spd-1000"|"ext4-spd-10000")
        mkfs.ext4 -q "$DEVICE"; # >"$RESULTS_DIR/mkfslog";
        dumpe2fs "$DEVICE" >"$RESULTS_DIR/fsinfo" 2>/dev/null;;
    "ext4-nodx")
        mkfs.ext4 -O ^dir_index -q "$DEVICE";
        dumpe2fs "$DEVICE" >"$RESULTS_DIR/fsinfo" 2>/dev/null;;
    "ext3")
        mkfs.ext3 $DEVICE >"$RESULTS_DIR/mkfslog" 2>/dev/null;;
    "xfs"|"xfs-defrag")
        mkfs.xfs -f "$DEVICE" >"$RESULTS_DIR/mkfslog" 2>/dev/null;;
    "btrfs")
        mkfs.btrfs $DEVICE >"$RESULTS_DIR/mkfslog" 2>/dev/null;;
esac

