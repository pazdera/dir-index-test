#!/bin/bash

# This file contains some performance tests for file
# system's directory index

FS="$1"
DEVICE="$2"
TEST_DIR="$3"
DROP_OFF_DIR="$4"
RES_DIR="$5"

PERF_DIR="$RES_DIR/perf"
mkdir -p "$PERF_DIR"

function time_benchmark
{
    local test_name=$1
    local cmd=$2

    sync && echo 3 > /proc/sys/vm/drop_caches
    sleep 5

    echo "Executing $test_name time benchmark"

    result=`(time ($cmd 2>/dev/null >/dev/null)) 2>&1`
    echo "$result" > "$PERF_DIR/$test_name.time"
}

# ls -l
time_benchmark "lsl" "ls -l $TEST_DIR"

# ls
time_benchmark "ls" "ls $TEST_DIR"

# getdents+stat
time_benchmark "getdents-stat" "bin/getdents-stat $TEST_DIR"

# getdents+stat
time_benchmark "readdir-stat" "bin/readdir-stat $TEST_DIR"

# find -name
time_benchmark "find" "find $TEST_DIR -type f"

# disk usage
time_benchmark "du" "du -hc $TEST_DIR"

# tar -cf
time_benchmark "tar" "tar -cf - $TEST_DIR"

# cp -a
now=`date +%s`
time_benchmark "cp" "cp -a $TEST_DIR $DROP_OFF_DIR/${now}-copy"
rm -rf "$DROP_OFF_DIR/${now}-copy"
