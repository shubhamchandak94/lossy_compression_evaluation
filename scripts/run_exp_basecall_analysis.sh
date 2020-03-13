#!/bin/bash

ROOTDIR="/raid/shubham/nanopore_lossy_compression/data/Klebsiella_pneumoniae_INF032/"
EXPDIR=$ROOTDIR/experiments

# basecalling
./basecall.sh $ROOTDIR/fast5 $EXPDIR/basecalled_fastq/lossless.fastq

for i in {1..10}; do
    ./basecall.sh $EXPDIR/new_fast5/LFZip_maxerror_$i  $EXPDIR/basecalled_fastq/LFZip_maxerror_$i.fastq
    ./basecall.sh $EXPDIR/new_fast5/SZ_maxerror_$i  $EXPDIR/basecalled_fastq/SZ_$i.fastq
done

# basecalling analysis
./analysis_basecall_accuracy.sh $EXPDIR/basecalled_fastq/lossless.fastq $ROOTDIR/Klebsiella_pneumoniae_INF032_reference.fasta

for i in {1..10}; do
    ./analysis_basecall_accuracy.sh $EXPDIR/basecalled_fastq/LFZip_maxerror_$i.fastq $ROOTDIR/Klebsiella_pneumoniae_INF032_reference.fasta
    ./analysis_basecall_accuracy.sh $EXPDIR/basecalled_fastq/SZ_maxerror_$i.fastq $ROOTDIR/Klebsiella_pneumoniae_INF032_reference.fasta
done
