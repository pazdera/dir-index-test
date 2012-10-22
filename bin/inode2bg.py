#!/usr/bin/env python

import sys

inodes_per_bg = int(sys.argv[2])

f = open(sys.argv[1], "r")
for line in f:
    inode = int(line)
    bg = (inode - 1) / inodes_per_bg
    print bg
