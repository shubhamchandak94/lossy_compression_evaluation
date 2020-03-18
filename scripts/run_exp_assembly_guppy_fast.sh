#!/bin/bash

ROOTDIR="/raid/shubham/nanopore_lossy_compression/data/Klebsiella_pneumoniae_INF032/"
BASECALLDIR=$ROOTDIR/experiments/guppy_fast/basecalled_fastq_subsampled_4/
ASSEMBLYDIR=$ROOTDIR/experiments/guppy_fast/assembly_subsampled_4/
LEN="5.5m"

# assembly
./assembly_fast.sh $BASECALLDIR/lossless.fastq $ASSEMBLYDIR/lossless $LEN

for i in {1..10}; do
    ./assembly_fast.sh $BASECALLDIR/LFZip_maxerror_$i.fastq $ASSEMBLYDIR/LFZip_maxerror_$i $LEN
    ./assembly_fast.sh $BASECALLDIR/SZ_maxerror_$i.fastq $ASSEMBLYDIR/SZ_maxerror_$i $LEN
done

