#!/bin/bash

ROOTDIR="/raid/shubham/nanopore_lossy_compression/data/Staphylococcus_aureus_CAS38_02/"
EXPDIR=$ROOTDIR/experiments

# basecalling
./basecall_bonito.sh $ROOTDIR/fast5 $EXPDIR/bonito/basecalled_fastq/lossless.fastq

for i in {1..10}; do
    ./basecall_bonito.sh $EXPDIR/new_fast5/LFZip_maxerror_$i  $EXPDIR/bonito/basecalled_fastq/LFZip_maxerror_$i.fastq
    ./basecall_bonito.sh $EXPDIR/new_fast5/SZ_maxerror_$i  $EXPDIR/bonito/basecalled_fastq/SZ_$i.fastq
done

# basecalling analysis
./analysis_basecall_accuracy.sh $EXPDIR/bonito/basecalled_fastq/lossless.fastq $ROOTDIR/Klebsiella_pneumoniae_INF032_reference.fasta

for i in {1..10}; do
    ./analysis_basecall_accuracy.sh $EXPDIR/bonito/basecalled_fastq/LFZip_maxerror_$i.fastq $ROOTDIR/Klebsiella_pneumoniae_INF032_reference.fasta
    ./analysis_basecall_accuracy.sh $EXPDIR/bonito/basecalled_fastq/SZ_maxerror_$i.fastq $ROOTDIR/Klebsiella_pneumoniae_INF032_reference.fasta
done
