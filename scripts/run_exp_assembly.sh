#!/bin/bash

ROOTDIR="/raid/shubham/nanopore_lossy_compression/data/Klebsiella_pneumoniae_INF032/"
BASECALLDIR=$ROOTDIR/experiments/basecalled_fastq_subsampled_4/
ASSEMBLYDIR=$ROOTDIR/experiments/assembly_subsampled_4/
LEN="5.5m"

# assembly
./assembly.sh $BASECALLDIR/lossless.fastq $ASSEMBLYDIR/lossless $LEN

for i in {1..10}; do
    ./assembly.sh $BASECALLDIR/LFZip_maxerror_$i.fastq $ASSEMBLYDIR/LFZip_maxerror_$i $LEN
    ./assembly.sh $BASECALLDIR/SZ_maxerror_$i.fastq $ASSEMBLYDIR/SZ_maxerror_$i $LEN
done

