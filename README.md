# dir-index-test #

This is a set of tests and benchmarks. It can be used for assessing and
rating directory indexing of various linux file systems.

It is written in a combination of bash, python and tiny amount of C.

You can run the test by running the run\_test script

    ./run_tests.sh

You will need to change some values in the beginning of the run script.

**WARNING**: All data on the provided device will be DESTROYED

## Project Files
*   `bin/` - compiled C tools
*   `scripts/` - bash and python scripts
*   `src/` - sources of C tools
*   `LICENSE` - GNU GPLv3
*   `Makefile` - to build tools
*   `README.md`
*   `extract_results.sh` - extract interesting results
*   `fs_benchmark.sh` - perform a benchmark on a single fs for a
                        specific number of files
*   `run_tests.sh` - execute the tests (watch for parameters inside!)

## Results
My results of these tests are available
[here](http://www.stud.fit.vutbr.cz/~xpazde00/ext4-tests/).

## Author
Radek Pazdera <rpazdera@redhat.com>  
[http://www.linuxwell.com](http://www.linuxwell.com)
