#!/usr/bin/env python

import os
import sys
import random
import errno

def create_clean_dir(path, count, file_size_range, numbered_from=0):
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

    dirname = os.path.basename(path)
    location = os.path.dirname(path)
    print "Created directory %s in %s" % (dirname, location)

    # create `count` files of half size
    half_size_range = (size_range[0]/2, size_range[1]/2)
    write_files(path, count, half_size_range)

    # resize and rename every first file
    fsiz_min, fsiz_max = half_size_range
    file_content = 'Y' * fsiz_max

    odd_files = range(1, count, 2)
    for i in odd_files:
        file_path = "%s/%d" % (path, i)
        file_len = random.randint(fsiz_min, fsiz_max)

        fd = os.open(file_path, os.O_RDWR | os.O_APPEND)
        os.write(fd, file_content[0:file_len])
        #os.fsync(fd)
        os.close(fd)

        suffix = "-really_long_file_name_suffix_to_mess_up_the_htree"
        os.rename(file_path, file_path + suffix)

    os.system("sync")

    # delete every second file
    even_files = range(0, count, 2)
    for i in even_files:
        file_path = "%s/%d" % (path, i)
        os.unlink(file_path)

    os.system("sync")

    # recreate even files but bigger
    fsiz_min, fsiz_max = size_range
    file_content = 'Y' * fsiz_max

    for i in even_files:
        file_path = "%s/%d%s" % (path, i, suffix)
        file_len = random.randint(fsiz_min, fsiz_max)

        fd = os.open(file_path, os.O_RDWR | os.O_CREAT)
        os.write(fd, file_content[0:file_len])
        #os.fsync(fd)
        os.close(fd)

    os.system("sync")
    print "Written %d bytes in %d files" % (count)


def write_files(target_dir, count, size_range,
                numbered_from=0, name_prefix=""):
    fsiz_min, fsiz_max = size_range
    file_content = 'X' * fsiz_max
    total_size = 0
    for i in range(count):
        file_path = "%s/%s%d" % (target_dir, name_prefix, (numbered_from + i))
        file_len = random.randint(fsiz_min, fsiz_max)
        total_size += file_len

        fd = os.open(file_path, os.O_RDWR | os.O_CREAT)
        os.write(fd, file_content[0:file_len])
        #os.fsync(fd)
        os.close(fd)

    os.system("sync")
    return total_size


def main():
    if len(sys.argv) <= 1:
        print "Usage: %s clean|dirty path nfiles fsize numbered_from"
        return 1

    path = sys.argv[2]
    nfiles = int(sys.argv[3])
    fsize = int(sys.argv[4])
    numbered_from = int(sys.argv[5])

    if sys.argv[1] == "dirty":
        create_dirty_dir(path, nfiles, (fsize, fsize), numbered_from)
    else:
        create_clean_dir(path, nfiles, (fsize, fsize), numbered_from)

    return 0

if __name__ == "__main__":
    sys.exit(main())
