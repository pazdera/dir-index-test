#!/bin/bash

# This script contains several seekwatcher test cases that
# can be used for assessing file system's directory indexes

DEVICE="$1"
FS="$2"
TEST_DIR="$3"
RES_DIR="$4"

SW_DIR="$RES_DIR/seekwatcher"
mkdir -p "$SW_DIR"

function seekwatcher_benchmark
{
    local test_name=$1
    local cmd=$2

    echo "Executing $test_name seekwatcher benchmark"

    sync && echo 3 > /proc/sys/vm/drop_caches

    blktrace -d "$DEVICE" -o "$SW_DIR/$test_name" -b 2048 &
#            -a queue -a complete -a issue &
    local blktrace_pid=`echo $!`

    $cmd >/dev/null 2>/dev/null

    kill -s SIGTERM $blktrace_pid
    seekwatcher -t "$SW_DIR/$test_name" -o "$RES_DIR/$test_name.png"

    # This doesn't work on my system.
    # Sometimes it just hangs when the command is finished.
    #(seekwatcher -t "$rdir/$test_name.trace" \
    #        -o "$rdir/$test_name-seekwatcher.png" \
    #        -p "$cmd 2>/dev/null >/dev/null" \
    #        -d "$DEVICE") > "$rdir/$test_name.seekwatcher"
}

# getdents+stat
seekwatcher_benchmark "dirstat" "bin/dirstat $TEST_DIR"

# ls
seekwatcher_benchmark "ls" "ls $TEST_DIR"

# find -name
seekwatcher_benchmark "find" "find $TEST_DIR -type f"

# tar -cf
seekwatcher_benchmark "tar" "tar -cf - $TEST_DIR"

# cp -a
seekwatcher_benchmark "cp" "cp -a $TEST_DIR $TEST_DIR.copy"
rm -rf "$TEST_DIR.copy"
