#!/bin/bash

# test parameters:
#   DEVICE: The disk partition to be used for testing. In order to avoid
#           distortion of the results, it should be the only partition on
#           a physical device.
#
#   DROP_OFF_DIR: A directory outside of the testing DEVICE. This directory
#                 will be used as a target for copy benchmarks.
#
#   FILESYSTEMS: A list of file systems to be tested.

DEVICE="/dev/disk/by-id/ata-WDC_WD2500AAKX-083CA0_WD-WCAYW0198571-part1" #"$1"
DROP_OFF_DIR="/mnt/Reserved/drop-off" #"$2"
RESULTS_DIR="results/"
FILESYSTEMS="ext4-nodx ext4"

# Prepare all the tools
make -B

for fs in $FILESYSTEMS; do
    dirsize=10000
    while [ $dirsize -lt 250000 ]; do
        ./fs_benchmark.sh "$fs" "$dirsize" "$DEVICE" \
                    "$DROP_OFF_DIR" "$RESULTS_DIR"
        let dirsize=dirsize*2
    done

    dirsize=250000
    while [ $dirsize -lt 1500000 ]; do
        ./fs_benchmark.sh "$fs" "$dirsize" "$DEVICE" \
                    "$DROP_OFF_DIR" "$RESULTS_DIR"
        let dirsize=dirsize+250000
    done
done

bin/process_results.sh "results"
