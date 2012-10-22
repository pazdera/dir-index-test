#!/bin/bash

DEVICE="/dev/disk/by-id/ata-WDC_WD2500AAKX-083CA0_WD-WCAYW0198571-part1" #"$1"
#FSs="ext4"
FSs="ext4 xfs btrfs jfs"

for fs in $FSs; do 
    DIRSIZE=10000
    while [ $DIRSIZE -lt 250000 ]; do #1500000
        ./fs_benchmark.sh "$DEVICE" "$fs" "$DIRSIZE"
        let DIRSIZE=DIRSIZE*2
    done

    DIRSIZE=250000
    while [ $DIRSIZE -lt 1500000 ]; do #1500000
        ./fs_benchmark.sh "$DEVICE" "$fs" "$DIRSIZE"
        let DIRSIZE=DIRSIZE+250000
    done
done

bin/plot_perf_graphs.sh "results"
