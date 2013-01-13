#!/bin/bash

# This include contains parameters handling and other functions for testing
. tests/tests-common.sh

now=`date +%s`
run_test "cp -a $TEST_DIR $DROP_OFF_DIR/${now}-copy"
rm -rf "$DROP_OFF_DIR/${now}-copy"
