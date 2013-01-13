#!/bin/bash

# Test case: ls

# This include contains parameters handling and other functions for testing
. tests/tests-common.sh

run_test "ls $TEST_DIR"
