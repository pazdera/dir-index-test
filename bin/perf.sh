#!/bin/bash

# This file contains some performance tests for file
# system's directory index

DEVICE="$1"
FS="$2"
TEST_DIR="$3"
RES_DIR="$4"

PERF_DIR="$RES_DIR/perf"
mkdir -p "$PERF_DIR"

function time_benchmark
{
    local test_name=$1
    local cmd=$2

    sync && echo 3 > /proc/sys/vm/drop_caches

    echo "Executing $test_name time benchmark"

    result=`(time ($cmd 2>/dev/null >/dev/null)) 2>&1`
    echo "$result" > "$PERF_DIR/$test_name.time"
}

# getdents+stat
time_benchmark "dirstat" "bin/dirstat $TEST_DIR"

# ls
time_benchmark "ls" "ls $TEST_DIR"

# find -name
time_benchmark "find" "find $TEST_DIR -type f"

# disk usage
time_benchmark "du" "du -hc $TEST_DIR"

# tar -cf
time_benchmark "tar" "tar -cf - $TEST_DIR"

# cp -a
time_benchmark "cp" "cp -a $TEST_DIR $TEST_DIR.copy"
rm -rf "$TEST_DIR.copy"
