#!/bin/bash

ROOTDIR=$WORKINGDIR/data/Klebsiella_pneumoniae_INF032/

# set following based on guppy model
DIRNAME="guppy_hac"
#DIRNAME="guppy_fast"

# set following based on guppy model and pore version
MEDAKAMODEL=r941_min_high_g360 
#MEDAKAMODEL=r941_min_fast_g303
#MEDAKAMODEL=r103_min_high_g360

BASECALLDIR=$ROOTDIR/experiments/$DIRNAME/basecalled_fastq/
ASSEMBLYDIR=$ROOTDIR/experiments/$DIRNAME/assembly/
LEN="5.5m"

mkdir -p $ASSEMBLYDIR

# assembly
./assembly_guppy.sh $BASECALLDIR/lossless.fastq $ASSEMBLYDIR/lossless $LEN $MEDAKAMODEL

for i in {1..10}; do
    ./assembly_guppy.sh $BASECALLDIR/LFZip_maxerror_$i.fastq $ASSEMBLYDIR/LFZip_maxerror_$i $LEN $MEDAKAMODEL
    ./assembly_guppy.sh $BASECALLDIR/SZ_maxerror_$i.fastq $ASSEMBLYDIR/SZ_maxerror_$i $LEN $MEDAKAMODEL
done
