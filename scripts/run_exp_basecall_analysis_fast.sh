#!/bin/bash

ROOTDIR="/raid/shubham/nanopore_lossy_compression/data/Staphylococcus_aureus_CAS38_02/"
FASTA_FILE=$ROOTDIR/"Staphylococcus_aureus_CAS38_02_reference.fasta"
EXPDIR=$ROOTDIR/experiments/

# basecalling
#./basecall_fast.sh $ROOTDIR/fast5 $EXPDIR/guppy_fast/basecalled_fastq/lossless.fastq

#for i in {1..10}; do
#    ./basecall_fast.sh $EXPDIR/new_fast5/LFZip_maxerror_$i  $EXPDIR/guppy_fast/basecalled_fastq/LFZip_maxerror_$i.fastq
#    ./basecall_fast.sh $EXPDIR/new_fast5/SZ_maxerror_$i  $EXPDIR/guppy_fast/basecalled_fastq/SZ_maxerror_$i.fastq
#done

# basecalling analysis
./analysis_basecall_accuracy.sh $EXPDIR/guppy_fast/basecalled_fastq/lossless.fastq $FASTA_FILE

for i in {1..10}; do
    ./analysis_basecall_accuracy.sh $EXPDIR/guppy_fast/basecalled_fastq/LFZip_maxerror_$i.fastq $FASTA_FILE
    ./analysis_basecall_accuracy.sh $EXPDIR/guppy_fast/basecalled_fastq/SZ_maxerror_$i.fastq $FASTA_FILE
done
