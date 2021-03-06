#!/bin/bash

RESULTS_DIR="$1"
TYPES="$2"

rm -f $RESULTS_DIR/*.dat
rm -f $RESULTS_DIR/*.png

scripts/gather_times.sh "$RESULTS_DIR" "$TYPES"
scripts/fmt_result_data.py "$RESULTS_DIR"

cd "$RESULTS_DIR"

for type in $TYPES; do
    plot_cmd="plot"
    for data_file in `ls -d $type.*.dat`; do
        fs_type=`echo "$data_file" | sed "s/$type\.\([^\.]*\)\.dat/\1/"`
        plot_cmd=" $plot_cmd '$data_file' title '$fs_type' with linespoints,"
    done
    plot_cmd=`echo "$plot_cmd" | sed "s/,$//"`

    gnuplot <<EOF
    set grid
    set autoscale
    set xtic auto
    set ytic auto
    set format y "%.0f"
    set title "$type"
    set xlabel "Number of files"
    set ylabel "Seconds"
    set terminal png nocrop enhanced font ",10" size 1440,900
    set output "$type.png"
    $plot_cmd
EOF
done
