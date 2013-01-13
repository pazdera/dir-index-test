#!/bin/bash

# This include contains parameters handling and other functions for testing
. tests/tests-common.sh

run_test "bin/readdir-stat $TEST_DIR"
