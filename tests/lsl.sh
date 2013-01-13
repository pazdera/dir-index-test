#!/bin/bash

# Test case: ls -l

# This include contains parameters handling and other functions for testing
. tests/tests-common.sh

run_test "ls -l $TEST_DIR"
