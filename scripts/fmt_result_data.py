#!/usr/bin/env python

import os
import sys
import re
import pprint

NFMT = "{:<12}"

def main():
    try:
        res_dir = sys.argv[1]
    except:
        sys.stderr.write("Usage: %s results_dir\n" % sys.argv[0])
        return 1

    data = {}
    for fn in os.listdir(res_dir):
        fn_match = re.match("([^\.]+)\.([^.]+)\.dat", fn)
        if fn_match:
            path = "%s/%s" % (res_dir, fn)
            tt = fn_match.group(1)
            fs = fn_match.group(2)

            fh = open(path, "r")
            for line in fh:
                line_match = re.match("([0-9\.]+)\s+([0-9\.]+)", line)
                if line_match:
                    nfiles = float(line_match.group(1))
                    duration = float(line_match.group(2))

                    if not tt in data:
                        data[tt] = {}
                    if not nfiles in data[tt]:
                        data[tt][nfiles] = {}

                    data[tt][nfiles][fs] = duration

    for tt in data.iterkeys():
        rows = set()
        cols = set()
        for nfiles in sorted(data[tt].iterkeys()):
            for fs in sorted(data[tt][nfiles].iterkeys()):
                rows.add(nfiles)
                cols.add(fs)

        fh = open("%s/%s.results" % (res_dir, tt), "w")
        header = NFMT.format("# nfiles")
        for fs in sorted(cols):
            header += NFMT.format(fs)
        header = "%s\n" % (header.strip())
        fh.write("# Results of %s tests\n" % tt)
        fh.write(header)

        for nfiles in sorted(rows):
            row = NFMT.format(nfiles)
            for fs in sorted(cols):
                try:
                    value = NFMT.format(data[tt][nfiles][fs])
                except:
                    value = NFMT.format("-")

                row += value

            row = "%s\n" % row.strip()
            fh.write(row)

        fh.close()

if __name__ == "__main__":
    sys.exit(main())
