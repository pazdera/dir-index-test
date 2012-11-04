#!/bin/bash

RESULTS_DIR="$1"
TYPES="create delete getdents-stat readdir-stat lsl ls du find tar cp"

for fsdir in `ls "$RESULTS_DIR"`; do
    if [ -d "$RESULTS_DIR/$fsdir" ]; then
        echo "$fsdir"
        for countdir in `ls "$RESULTS_DIR/$fsdir" | sort -n`; do
            if [ -d "$RESULTS_DIR/$fsdir/$countdir" ]; then
                nfiles=`echo "$countdir" | sed "s/_files$//"`
                echo "  $nfiles"
                for type in $TYPES; do
                    echo "    $type"
                    data_file="$RESULTS_DIR/$fsdir/$countdir/perf/$type.time"
                    if [ -e "$data_file" ]; then
                        tv=`cat "$data_file"`
                        touch "$RESULTS_DIR/$type.$fsdir.dat"
                        echo "$nfiles $tv" >>"$RESULTS_DIR/$type.$fsdir.dat"
                    fi
                done
            fi
        done
    fi
done
