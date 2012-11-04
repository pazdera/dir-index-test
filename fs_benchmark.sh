#!/bin/bash

# parameters:
#   device
#   fs
#   number of files to create

FS="$1"
DIRSIZE="$2"
DEVICE="$3"
DROP_OFF_DIR="$4"
RESULTS_DIR="$5"

FSIZE=4096

mount_point="`mktemp -d`"
test_dir="$mount_point/test_dir.$$"

# results root for the current settings
rroot="$RESULTS_DIR/$FS/${DIRSIZE}_files"
mkdir -p "$rroot"

# initialize results dir structure
locdir="$rroot/locality"
mkdir -p "$locdir"
perfdir="$rroot/perf"
mkdir -p "$perfdir"
swdir="$rroot/seekwatcher"
mkdir -p "$swdir"

export TIMEFORMAT="%3R"

# prepare file system
bin/prepfs.sh "$FS" "$DEVICE" "$rroot"

# Set preload lib for spd test
if [ "$FS" == "ext4-spd" ]; then
    export LD_PRELOAD=`pwd`"/spd_readdir.so"
else
    export LD_PRELOAD=""
fi

# mount it
echo "Mounting $DEVICE to $mount_point"
mkdir -p "$mount_point"
mount "$DEVICE" "$mount_point"

# create directory
mkdir -p "$test_dir"
echo "Creating $DIRSIZE files"
time (bin/create_files.py "clean" "$test_dir" \
            $DIRSIZE "$FSIZE" "0" >/dev/null) 2>"$perfdir/create.time"

# tests
bin/locality.sh "$FS" "$DEVICE" "$test_dir" "$rroot"
bin/perf.sh "$FS" "$DEVICE" "$test_dir" "$DROP_OFF_DIR" "$rroot"
bin/seekwatcher.sh "$FS" "$DEVICE" "$test_dir" "$DROP_OFF_DIR" "$rroot"

echo "Deleting files"
time (rm -rf "$test_dir" >/dev/null) 2>"$perfdir/delete.time"

echo "Umounting $DEVICE"
umount "$DEVICE"

echo "Removing temporary mount point"
rm -rf "$mount_point"
