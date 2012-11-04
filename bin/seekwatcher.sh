#!/bin/bash

# This script contains several seekwatcher test cases that
# can be used for assessing file system's directory indexes

FS="$1"
DEVICE="$2"
TEST_DIR="$3"
DROP_OFF_DIR="$4"
RES_DIR="$5"

SW_DIR="$RES_DIR/seekwatcher"
mkdir -p "$SW_DIR"

function seekwatcher_benchmark
{
    local test_name=$1
    local cmd=$2

    echo "Executing $test_name seekwatcher benchmark"

    sync && echo 3 > /proc/sys/vm/drop_caches
    sleep 5

    blktrace -d "$DEVICE" -o "$SW_DIR/$test_name" >/dev/null &
#            -a queue -a complete -a issue -b 2048 &
    local blktrace_pid=`echo $!`

    $cmd >/dev/null 2>/dev/null

    kill -s SIGTERM $blktrace_pid
    seekwatcher -t "$SW_DIR/$test_name" -o "$RES_DIR/$test_name.png" >/dev/null

    # This doesn't work on my system.
    # Sometimes it just hangs when the command is finished.
    #(seekwatcher -t "$rdir/$test_name.trace" \
    #        -o "$rdir/$test_name-seekwatcher.png" \
    #        -p "$cmd 2>/dev/null >/dev/null" \
    #        -d "$DEVICE") > "$rdir/$test_name.seekwatcher"
}

# ls -l
seekwatcher_benchmark "lsl" "ls -l $TEST_DIR"

# ls
seekwatcher_benchmark "ls" "ls $TEST_DIR"

# getdents+stat
seekwatcher_benchmark "getdents-stat" "bin/getdents-stat $TEST_DIR"

# readdir+stat
seekwatcher_benchmark "readdir-stat" "bin/readdir-stat $TEST_DIR"

# find -name
seekwatcher_benchmark "find" "find $TEST_DIR -type f"

# tar -cf
seekwatcher_benchmark "tar" "tar -cf - $TEST_DIR"

# cp -a
now=`date +%s`
seekwatcher_benchmark "cp" "cp -a $TEST_DIR $DROP_OFF_DIR/${now}-copy"
rm -rf "$DROP_OFF_DIR/${now}-copy"
