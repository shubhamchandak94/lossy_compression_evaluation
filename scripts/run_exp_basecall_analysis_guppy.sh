#!/bin/bash

ROOTDIR=$WORKINGDIR/data/Klebsiella_pneumoniae_INF032/
FASTA_FILE=$ROOTDIR/"Klebsiella_pneumoniae_INF032_reference.fasta"

# set following based on guppy mode
EXPDIR=$ROOTDIR/experiments/guppy_hac/
#EXPDIR=$ROOTDIR/experiments/guppy_fast/

BASECALLDIR=$EXPDIR/basecalled_fastq/

# set following based on guppy mode
GUPPY_CONFIG="dna_r9.4.1_450bps_hac.cfg"
#GUPPY_CONFIG="dna_r9.4.1_450bps_fast.cfg"
#GUPPY_CONFIG="dna_r10.3_450bps_hac.cfg"
#GUPPY_CONFIG="dna_r10.3_450bps_fast.cfg"

mkdir -p $BASECALLDIR

# basecalling
#./basecall_guppy.sh $ROOTDIR/fast5 $BASECALLDIR/lossless.fastq $GUPPY_CONFIG

for i in 5 10; do #{1..10}; do
    ./basecall_guppy.sh $ROOTDIR/experiments/new_fast5/LFZip_maxerror_$i  $BASECALLDIR/LFZip_maxerror_$i.fastq $GUPPY_CONFIG
    ./basecall_guppy.sh $ROOTDIR/experiments/new_fast5/SZ_maxerror_$i  $BASECALLDIR/SZ_maxerror_$i.fastq $GUPPY_CONFIG
done

# basecalling analysis
#./analysis_basecall_accuracy.sh $BASECALLDIR/lossless.fastq $FASTA_FILE

for i in 5 10; do #{1..10}; do
    ./analysis_basecall_accuracy.sh $BASECALLDIR/LFZip_maxerror_$i.fastq $FASTA_FILE
    ./analysis_basecall_accuracy.sh $BASECALLDIR/SZ_maxerror_$i.fastq $FASTA_FILE
done
