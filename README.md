# dir-index-test #

This is a set of tests and benchmarks. It can be used for assessing and
rating directory indexing of various linux file systems.

It is written in a combination of bash, python and tiny amount of C.

After building the test tools with

    make

you can run the test by running the run_test script

    ./run_tests.sh <device>

**WARNING**: All data on the provided device will be DESTROYED

## Project Files
    * bin/ - various tools
    * src/ - sources of C tools
    * LICENSE - GNU GPLv3
    * README
    * Makefile - to build tools

## Author
    <xpazde00@stud.fit.vutbr.cz> Radek Pazdera
    www.linuxwell.com
