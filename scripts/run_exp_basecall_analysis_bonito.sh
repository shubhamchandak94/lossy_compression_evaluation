#!/bin/bash
set -e
ROOTDIR="/raid/shubham/nanopore_lossy_compression/data/Klebsiella_pneumoniae_INF032/"
REFFILE=$ROOTDIR/Klebsiella_pneumoniae_INF032_reference.fasta
EXPDIR=$ROOTDIR/experiments

#basecalling
./basecall_bonito.sh $ROOTDIR/fast5 $EXPDIR/bonito/basecalled_fastq/lossless.fastq

for i in {1..10}; do
    ./basecall_bonito.sh $EXPDIR/new_fast5/LFZip_maxerror_$i  $EXPDIR/bonito/basecalled_fastq/LFZip_maxerror_$i.fastq
    ./basecall_bonito.sh $EXPDIR/new_fast5/SZ_maxerror_$i  $EXPDIR/bonito/basecalled_fastq/SZ_maxerror_$i.fastq
done

# basecalling analysis
./analysis_basecall_accuracy.sh $EXPDIR/bonito/basecalled_fastq/lossless.fastq $REFFILE
for i in {1..10}; do
    ./analysis_basecall_accuracy.sh $EXPDIR/bonito/basecalled_fastq/LFZip_maxerror_$i.fastq $REFFILE
    ./analysis_basecall_accuracy.sh $EXPDIR/bonito/basecalled_fastq/SZ_maxerror_$i.fastq $REFFILE
done
