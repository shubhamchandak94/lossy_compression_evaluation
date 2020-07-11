#!/bin/bash

ROOTDIR=$WORKINGDIR/data/Klebsiella_pneumoniae_INF032/
BASECALLDIR=$ROOTDIR/experiments/bonito/basecalled_fastq/
ASSEMBLYDIR=$ROOTDIR/experiments/bonito/assembly/
LEN="5.5m"

# assembly
./assembly_bonito.sh $BASECALLDIR/lossless.fastq $ASSEMBLYDIR/lossless $LEN

for i in {1..10}; do
    ./assembly_bonito.sh $BASECALLDIR/LFZip_maxerror_$i.fastq $ASSEMBLYDIR/LFZip_maxerror_$i $LEN
    ./assembly_bonito.sh $BASECALLDIR/SZ_maxerror_$i.fastq $ASSEMBLYDIR/SZ_maxerror_$i $LEN
done

