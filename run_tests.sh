#!/bin/bash

# dir-index-test
# author: Radek Pazdera (rpazdera@redhat.com)

# Test Parameters:
#   DEVICE: The disk partition to be used for testing. In order to avoid
#           distortion of the results, it should be the only partition on
#           a physical device.
#
#   DROP_OFF_DIR: A directory outside of the testing DEVICE. This directory
#                 will be used as a target for copy benchmarks.
#
#   FILESYSTEMS: A list of file systems to be tested.
#                Currently supported:
#                   btrfs ext4 ext4-spd ext4-nodx jfs xfs
#
#   FSIZES: A list of file sizes to test for (for each test $dirsize number
#           of $fsize files will be created)
#
#   TESTS: A list of wrappers that the test cases will be used with.
#          Wrappers are implemented in tests/tests-common.sh
#          Currently supported:
#               perf - will measure the duration of a test case
#               seekwatcher - will trace I/O during a test case
#
#   TEST_CASES: Small benchmarks that will be run with different wrappers
#               to measure different things. They are implemented in tests/*.sh
#               Currently supported:
#                   cp find ls lsl tar getdents-stat readdir-stat
#
#   DIR_TYPE: Type of directory to be generated for the test, such as clean
#             dir or aged.
#             Currently supported:
#                 clean dirty
#
#   DIR_SIZES: Sizes of directories to perform the benchmarks on.
#
DEVICE="/dev/disk/by-id/ata-WDC_WD2500AAKX-083CA0_WD-WCAYW0198571-part1"
DROP_OFF_DIR="/mnt/Reserved/drop-off"
RESULTS_DIR="results-ext4/"
FILESYSTEMS="ext4 xfs btrfs" # ext4-spd-10000 ext4-spd" # ext4-spd xfs btrfs" # jfs

# XXX WARNING: This is only for ext4_comparison!
EXT4_MODES="spd 1000 10000 50000 normal"


FSIZES="0 4096"
TESTS="perf" # seekwatcher
TEST_CASES="cp readdir-stat getdents-stat" # find tar cp lsl ls getdents-stat
DIR_TYPE="clean"
DIR_SIZES="10000 25000 50000 100000 250000 500000 750000 \
           1000000 1250000 1500000 1750000 2000000"


function run_ext4_comparison
{
    fs="$1"
    dirsize="$2"
    fsize="$3"

    echo "Executing $fs benchmark for $dirsize files [${fsize}B each]"
    ./ext4_comparison.sh "$fs" "$dirsize" "$fsize" \
        "$DEVICE" "$DROP_OFF_DIR" "$RESULTS_DIR/$fsize" \
        "$TESTS" "$TEST_CASES" "$DIR_TYPE"

    if [ $? -ne 0 ]; then
        echo "Comparison failed!"
        exit 1
    fi
}

function run_benchmark
{
    fs="$1"
    dirsize="$2"
    fsize="$3"

    echo "Executing $fs benchmark for $dirsize files [${fsize}B each]"
    ./fs_benchmark.sh "$fs" "$dirsize" "$fsize" \
        "$DEVICE" "$DROP_OFF_DIR" "$RESULTS_DIR/$fsize" \
        "$TESTS" "$TEST_CASES" "$DIR_TYPE"

    if [ $? -ne 0 ]; then
        echo "Benchmark failed!"
        exit 1
    fi
}

# This will run fs_benchmark.sh script for every fs
# in $FILESYSTEMS and for every dir size $DIR_SIZES.
#
# The `fsize` parameter represents the size of each
# individual file that will be created during the
# test in the testing directory.
#
# Set $fsize = 0 to run the tests only with metadata.
function run_benchmark_series
{
    fsize="$1"

    for fs in $FILESYSTEMS; do
        for dirsize in $DIR_SIZES; do
            run_benchmark "$fs" "$dirsize" "$fsize"
        done
    done

    scripts/process_results.sh "$RESULTS_DIR/$fsize" \
                               "create delete $TEST_CASES"
}

make -B
for fsize in $FSIZES; do
    run_benchmark_series "$fsize"
done
make clean
