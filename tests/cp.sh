#!/bin/bash

# This include contains parameters handling and other functions for testing
. tests/tests-common.sh

now=`date +%s`
target="$DROP_OFF_DIR/${now}-copy"
run_test "cp -a $TEST_DIR $target"
echo "[DONE]"

let source_size=`ls -1a $TEST_DIR | wc -l`-2
echo "  Source directory has $source_size files"

let target_size=`ls -1a $target | wc -l`-2
echo "  Target directory has $target_size files"

let diff=$source_size-$target_size
if [ $diff -ne 0 ]; then
    echo -n "Copy operation did not finish ... [WARNING]"
else
    echo -n "Copying ... "
fi

rm -rf "$DROP_OFF_DIR/${now}-copy"
