#!/bin/bash

# This script will perform several tests of directory entries
# and a correlation of the order in which they are returned
# from getdents(2) and their position on the disk

DEVICE="$1"
FS="$2"
TEST_DIR="$3"
RES_DIR="$4"

LOC_DATA_DIR="$RES_DIR/locality"
mkdir -p "$LOC_DATA_DIR"

LOC_STATS_FILE="$RES_DIR/locality_stats"
echo "# Locality stats #" > "$LOC_STATS_FILE"


function ext4_inodes_per_group
{
    local dev=$1
    local label="Inodes per group:"
    retval=`tune2fs -l "$dev" | grep "$label" | sed "s/$label\s*//"`
    echo "$retval"
}

function ext4_groups_per_flex
{
    local dev=$1
    local label="Flex block group size:"
    retval=`tune2fs -l "$dev" | grep "$label" | sed "s/$label\s*//"`
    echo "$retval"
}

function process_data
{
    local file="$1"
    local testtype="$2"

    bin/crunch.py "$file" > "$file.stats"
    echo "## $testtype order stats ##" | cat - "$file.stats" \
                        >>"$LOC_STATS_FILE"

    cat -n "$file" >"$file.dat"
    bin/plot_correlation.sh "$testtype" "$file.dat" \
                "$RES_DIR/${testtype}_order.png"
}

# ---
bin/lsino "$TEST_DIR" >"$LOC_DATA_DIR/inode_order"
process_data "$LOC_DATA_DIR/inode_order" "inode"

# looks like btrfs does not implement FIBMAP which
# is necessary to perform this test
if [ "$FS" != "btrfs" ]; then
    bin/lsblk "$TEST_DIR" >"$LOC_DATA_DIR/blk_order"
    process_data "$LOC_DATA_DIR/blk_order" "blk"
fi

# only ext4 has block groups
if [ "$FS" == "ext4" ]; then
    ipg=`ext4_inodes_per_group "$DEVICE"`
    bin/inode2bg.py "$LOC_DATA_DIR/inode_order" $ipg >"$LOC_DATA_DIR/bg_order"
    process_data "$LOC_DATA_DIR/bg_order" "bg"
fi
