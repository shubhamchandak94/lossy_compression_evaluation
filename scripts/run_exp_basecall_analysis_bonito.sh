#!/bin/bash
set -e
ROOTDIR=$WORKINGDIR/data/Klebsiella_pneumoniae_INF032/
FASTAFILE=$ROOTDIR/"Klebsiella_pneumoniae_INF032_reference.fasta"
EXPDIR=$ROOTDIR/experiments/bonito/
BASECALLDIR=$EXPDIR/basecalled_fastq/

mkdir -p $BASECALLDIR

#basecalling
./basecall_bonito.sh $ROOTDIR/fast5 $BASECALLDIR/lossless.fastq

for i in {1..10}; do
    ./basecall_bonito.sh $ROOTDIR/experiments/new_fast5/LFZip_maxerror_$i  $BASECALLDIR/LFZip_maxerror_$i.fastq
    ./basecall_bonito.sh $ROOTDIR/experiments/new_fast5/SZ_maxerror_$i  $BASECALLDIR/SZ_maxerror_$i.fastq
done

# basecalling analysis
./analysis_basecall_accuracy.sh $BASECALLDIR/lossless.fastq $FASTAFILE
for i in {1..10}; do
    ./analysis_basecall_accuracy.sh $BASECALLDIR/LFZip_maxerror_$i.fastq $FASTAFILE
    ./analysis_basecall_accuracy.sh $BASECALLDIR/SZ_maxerror_$i.fastq $FASTAFILE
done
