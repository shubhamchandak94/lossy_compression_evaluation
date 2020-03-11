#!/bin/bash

ROOTDIR="/raid/shubham/nanopore_lossy_compression/data/Klebsiella_pneumoniae_INF032/"
EXPDIR=$ROOTDIR/experiments

source /raid/shubham/nanopore_lossy_compression/LFZip/src/env/bin/activate

for i in {1..10}; do
    ./generate_lossy_fast5.py --inDir $ROOTDIR/fast5 --summaryFile $EXPDIR/compressed_size_summary/SZ_maxerror_$i.tsv --compressor SZ --outDir $EXPDIR/new_fast5/SZ_maxerror_$i --maxError $i &> $EXPDIR/logs/run_exp_generate_fast5.SZ_maxerror_$i.txt
done

for i in {1..10}; do
    ./generate_lossy_fast5.py --inDir $ROOTDIR/fast5 --summaryFile $EXPDIR/compressed_size_summary/LFZip_maxerror_$i.tsv --compressor LFZip --outDir $EXPDIR/new_fast5/LFZip_maxerror_$i --maxError $i &> $EXPDIR/logs/run_exp_generate_fast5.LFZip_maxerror_$i.txt
done

./generate_lossy_fast5.py --inDir $ROOTDIR/fast5 --summaryFile $EXPDIR/compressed_size_summary/VBZ_lossless.tsv --compressor VBZ &> $EXPDIR/logs/run_exp_generate_fast5.vbz.txt

deactivate
