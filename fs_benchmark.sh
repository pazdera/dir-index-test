#!/bin/bash

# dir-index-test
# author: Radek Pazdera (rpazdera@redhat.com)

# Script Parameters:
#   FS            fs
#   DIRSIZE       number of files to work with
#   FSIZE         size of individual files
#
#   DEVICE        device
#   DROP_OFF_DIR  empty test directory located on another
#                 file system (for copy tests)
#   RESULTS_DIR   directory to store the results to
#
#   TESTS         test wrappers to use
#   TEST_CASES    test cases to execute
#
#   DIR_TYPE      clean or dirty

FS="$1"
DIRSIZE="$2"
FSIZE="$3"

DEVICE="$4"
DROP_OFF_DIR="$5"
RESULTS_DIR="$6"

TESTS="$7"
TEST_CASES="$8"

DIR_TYPE="$9"

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
scripts/prepfs.sh "$FS" "$DEVICE" "$rroot"

# Set preload lib for spd test
if [ "$FS" == "ext4-spd" ]; then
    export SPD_READDIR_CACHE_LIMIT=0
    export LD_PRELOAD=`pwd`"/spd_readdir.so"
    mount_as="ext4"
elif [ "$FS" == "ext4-spd-1000" ]; then
    export SPD_READDIR_CACHE_LIMIT=1000
    export LD_PRELOAD=`pwd`"/spd_readdir.so"
    mount_as="ext4"
elif [ "$FS" == "ext4-spd-10000" ]; then
    export SPD_READDIR_CACHE_LIMIT=10000
    export LD_PRELOAD=`pwd`"/spd_readdir.so"
    mount_as="ext4"
else
    export LD_PRELOAD=""
    mount_as="$FS"
fi

# mount it
echo "Mounting $DEVICE to $mount_point"
mkdir -p "$mount_point"
mount -t "$mount_as" "$DEVICE" "$mount_point"
if [ $? -ne 0 ]; then
    echo "Unable to mount $DEVICE! Exiting."
    exit 1
fi

# create directory
mkdir -p "$test_dir"
echo "Creating $DIRSIZE files"
time (scripts/create_files.py "$DIR_TYPE" "$test_dir" \
            $DIRSIZE "$FSIZE" "0" >/dev/null) 2>"$perfdir/create.time"

if [ "$FS" == "xfs-defrag" ]; then
    xfs_db -r -c frag >"$locdir/frag"
    xfs_fsr "$DEVICE"
fi

tests/locality.sh "$FS" "$DEVICE" "$test_dir" "$rroot"

for ttype in $TESTS; do
    for tcase in $TEST_CASES; do
        # remount and drop caches
        umount "$DEVICE"
        sync; echo 3 > /proc/sys/vm/drop_caches
        sleep 3
        mount -t "$mount_as" "$DEVICE" "$mount_point"

        echo -n "Executing $tcase $ttype benchmark ... "
        tests/${tcase}.sh "$tcase" "$ttype" "$FS" "$DEVICE" \
                          "$test_dir" "$DROP_OFF_DIR" "$rroot"
        echo "[DONE]"
    done
done

# remount and drop caches
umount "$DEVICE"
sync; echo 3 > /proc/sys/vm/drop_caches
sleep 3
mount -t "$mount_as" "$DEVICE" "$mount_point"

echo "Deleting files"
time (rm -rf "$test_dir" >/dev/null) 2>"$perfdir/delete.time"

echo "Umounting $DEVICE"
umount "$DEVICE"

echo "Removing temporary mount point"
rm -rf "$mount_point"
