#!/bin/bash

ROOTDIR="/raid/shubham/nanopore_lossy_compression/data/Klebsiella_pneumoniae_INF032/"
EXPDIR=$ROOTDIR/experiments/guppy_fast
LEN="5.5m"

# assembly
./assembly.sh $EXPDIR/basecalled_fastq/lossless.fastq $EXPDIR/assembly/lossless $LEN

for i in {1..10}; do
    ./assembly.sh $EXPDIR/basecalled_fastq/LFZip_maxerror_$i.fastq $EXPDIR/assembly/LFZip_maxerror_$i $LEN
    ./assembly.sh $EXPDIR/basecalled_fastq/SZ_maxerror_$i.fastq $EXPDIR/assembly/SZ_maxerror_$i $LEN
done

