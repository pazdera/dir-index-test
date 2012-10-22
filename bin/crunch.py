#!/usr/bin/env python

import sys
import re

items = 0
min_item = 0
max_item = 0

items_in = 0
items_out = 0
last_item = 0

f = open(sys.argv[1], "r")
for line in f:
    item = int(line)

    if min_item > item or min_item == 0:
        min_item = item

    if max_item < item or max_item == 0:
        max_item = item

    if last_item != 0:
        if item > last_item:
            items_in += 1
        else:
            items_out += 1

    last_item = item
    items += 1

f.close()

print "Number of items: %d" % items
print "First item:      %d" % min_item
print "Last item:       %d" % max_item
print "Inode range:     %d" % (max_item - min_item)
print "Correlation:     %s" % str(float(items_in)/float(items))
