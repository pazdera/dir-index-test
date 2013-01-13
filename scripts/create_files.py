#!/usr/bin/env python

import os
import sys
import random
import errno

def create_clean_dir(path, count, file_size_range=(0,0), numbered_from=0):
    """
    Create `count` files in the directory specified by `path`

    Directory content will be created "cleanly", i.e.,
    written sequentialy using one process. File sizes are
    randomized within `file_size_range`.
    
    The directory must not exist, otherwise OSError will be
    raised.

    :param path: Targed nonexisting directory
    :type path: string

    :param count: Number of files to be created
    :type count: int

    :param file_size_range: Minimum and maximum file size
    :type file_size_range: 2-tuple

    :return: void
    :rtype: None
    """
    try:
        os.mkdir(path)
    except OSError as exc:
        if exc.errno == errno.EEXIST:
            pass
        else: raise

    path = os.path.abspath(path)
    dirname = os.path.basename(path)
    location = os.path.dirname(path)
    print "Created directory %s in %s" % (dirname, location)

    bytes_written = write_files(path, count, file_size_range, numbered_from)

    print "Written %d bytes in %d files" % (bytes_written, count)


def create_dirty_dir(path, count, size_range):
    """
    Create `count` files in the directory specified by `path`

    Directory content will be "dirty". This function tries
    to simulate file system aging. This is done by writing,
    deleting and renaming files on the disk.

    The directory must not exist, otherwise OSError will be
    raised.

    :param path: Targed nonexisting directory
    :type path: string

    :param count: Number of files to be created
    :type count: int

    :param file_size_range: Minimum and maximum file size
    :type file_size_range: 2-tuple

    :return: void
    :rtype: None
    """

    try:
        os.mkdir(path)
    except OSError as exc:
        if exc.errno == errno.EEXIST:
            pass
        else: raise

    path = os.path.abspath(path)
    dirname = os.path.basename(path)
    location = os.path.dirname(path)
    print "Created directory %s in %s" % (dirname, location)


    i = 1
    name = 0
    while i < count:
        rand = random.randint(1,100)
        if rand < 10 and i > 0:
            try:
                os.unlink("%s/%d" % (path, random.randint(0,name-1)))
                i-=1
            except:
                pass
        else:
            write_file(path, size_range, str(name))
            i+=1
        name += 1
            

    print "Written %d files" % (count)

def write_file(target_dir, size_range, name, file_content=None):
    fsiz_min, fsiz_max = size_range
    if not file_content:
        file_content = 'X' * fsiz_max

    file_path = "%s/%s" % (target_dir, str(name))
    file_len = random.randint(fsiz_min, fsiz_max)

    fd = os.open(file_path, os.O_RDWR | os.O_CREAT)
    os.write(fd, file_content[0:file_len])
    os.close(fd)

    return file_len

def write_files(target_dir, count, size_range,
                numbered_from=0, name_prefix=""):
    fsiz_min, fsiz_max = size_range
    file_content = 'X' * fsiz_max
    total_size = 0
    for i in range(count):
        file_name = "%s%d" % (name_prefix, (numbered_from + i))

        fsize = write_file(target_dir, size_range, file_name, file_content)
        total_size += fsize

    os.system("sync")
    return total_size


def main():
    if len(sys.argv) <= 1:
        print "Usage: %s clean|dirty path nfiles fsize numbered_from"
        return 1

    path = sys.argv[2]
    nfiles = int(sys.argv[3])
    fsize = int(sys.argv[4])

    if sys.argv[1] == "dirty":
        create_dirty_dir(path, nfiles, (fsize, fsize))
    else:
        numbered_from = int(sys.argv[5])
        create_clean_dir(path, nfiles, (fsize, fsize), numbered_from)

    return 0

if __name__ == "__main__":
    sys.exit(main())
