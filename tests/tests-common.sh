#!/bin/bash

# Common code for the test cases

TCASE="$1"
TTYPE="$2"
FS="$3"
DEVICE="$4"
TEST_DIR="$5"
DROP_OFF_DIR="$6"
RES_DIR="$7"

if [ $TTYPE == "perf" ]; then
    PERF_DIR="$RES_DIR/perf"
    mkdir -p "$PERF_DIR"
fi

if [ $TTYPE == "seekwatcher" ]; then
    SW_DIR="$RES_DIR/seekwatcher"
    mkdir -p "$SW_DIR"
fi

function perf_benchmark
{
    local test_name=$1
    local cmd=$2

    #echo "Executing $test_name perf benchmark"

    result=`(time ($cmd 2>/dev/null >/dev/null)) 2>&1`
    echo "$result" > "$PERF_DIR/$test_name.time"
}

function seekwatcher_benchmark
{
    local test_name=$1
    local cmd=$2

    #echo "Executing $test_name seekwatcher benchmark"

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

function run_test
{
    ${TTYPE}_benchmark "$TCASE" "$1"
}
