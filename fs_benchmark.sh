#!/bin/bash

# parameters:
#   device
#   fs
#   number of files to create

DEVICE="$1"
FS="$2"
DIRSIZE="$3"

MOUNT_POINT="`mktemp -d`"
TEST_DIR="$MOUNT_POINT/test_dir.$$"
FSIZE=4096

rdir="results/$FS/${DIRSIZE}_files"
mkdir -p "$rdir"

export TIMEFORMAT="%3R"

# prepare file system
umount "$DEVICE" >/dev/null 2>/dev/null
echo "Creating $FS file system on $DEVICE"
case $FS in
    "ext4")
        mkfs.ext4 -q "$DEVICE"; # >"$rdir/mkfslog";
        dumpe2fs "$DEVICE" >"$rdir/fsinfo" 2>/dev/null;;
    "ext3")
        mkfs.ext3 $DEVICE >"$rdir/mkfslog" 2>/dev/null;;
    "xfs")
        mkfs.xfs -f "$DEVICE" >"$rdir/mkfslog" 2>/dev/null;;
    "btrfs")
        mkfs.btrfs $DEVICE >"$rdir/mkfslog" 2>/dev/null;;
esac

# mount it
echo "Mounting $DEVICE to $MOUNT_POINT"
mkdir -p "$MOUNT_POINT"
mount "$DEVICE" "$MOUNT_POINT"

# create directory
mkdir -p "$TEST_DIR"
echo "Creating $DIRSIZE files"
bin/create_files.py "clean" "$TEST_DIR" $DIRSIZE "$FSIZE" "0" >/dev/null

# tests
bin/locality.sh "$DEVICE" "$FS" "$TEST_DIR" "$rdir"
bin/perf.sh "$DEVICE" "$FS" "$TEST_DIR" "$rdir"
bin/seekwatcher.sh "$DEVICE" "$FS" "$TEST_DIR" "$rdir"

echo "Umounting $DEVICE"
umount "$DEVICE"

echo "Removing temporary mount point"
rm -rf "$MOUNT_POINT"
