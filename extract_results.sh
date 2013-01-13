#!/bin/bash

# Extract interesting files from a directory with
# test results from dir-index-test

RESULTS_DIR="$1"
EXTRACT_DIR="$2"

for fsdir in `ls "$RESULTS_DIR"`; do
    if [ -d "$RESULTS_DIR/$fsdir" ]; then
        echo "$fsdir"
        for countdir in `ls "$RESULTS_DIR/$fsdir" | sort -n`; do
            current_dir="$RESULTS_DIR/$fsdir/$countdir"
            target_dir="$EXTRACT_DIR/$fsdir/$countdir"
            if [ -d "$current_dir" ]; then
                mkdir -p "$target_dir"
                cp `find "$current_dir/" -maxdepth 1 -type f` "$target_dir"
            fi
        done
    fi
done

cp `find "$RESULTS_DIR/" -maxdepth 1 -type f -name "*.png"` "$EXTRACT_DIR"
cp `find "$RESULTS_DIR/" -maxdepth 1 -type f -name "*.results"` "$EXTRACT_DIR"
