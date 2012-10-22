#!/bin/bash

PLOT_TYPE="$1"
DATA_FILE="$2"
OUTPUT_FILE="$3"

case $PLOT_TYPE in
    inode)
        title="Correlation of inode numbers to position in getdents output";
        xlabel="getdents position (read in htree order)";
        ylabel="inode number";;
    bg)
        title="Correlation of bg numbers to position in getdents output";
        xlabel="getdents position (read in htree order)";
        ylabel="block group number";;
    flexbg)
        title="Correlation of flex bg numbers to position in getdents output";
        xlabel="getdents position (read in htree order)";
        ylabel="flex block group number";;
    blk)
        title="Correlation of file's first block to position in getdents output";
        xlabel="getdents position (read in htree order)";
        ylabel="block number";;
esac

gnuplot <<EOF
set autoscale
set xtic auto
set ytic auto
set format y "%.0f"
set title "$title"
set xlabel "$xlabel"
set ylabel "$ylabel"
set terminal png nocrop enhanced font ",10" size 1440,900
set output "$OUTPUT_FILE"
plot "$DATA_FILE" with points
EOF
