#!/bin/bash

ROOTDIR="/raid/shubham/nanopore_lossy_compression/data/Staphylococcus_aureus_CAS38_02/"
BASECALLDIR=$ROOTDIR/experiments/bonito/basecalled_fastq/
ASSEMBLYDIR=$ROOTDIR/experiments/bonito/assembly/
LEN="2.9m"

# assembly
./assembly_bonito.sh $BASECALLDIR/lossless.fastq $ASSEMBLYDIR/lossless $LEN

for i in {1..10}; do
    ./assembly_bonito.sh $BASECALLDIR/LFZip_maxerror_$i.fastq $ASSEMBLYDIR/LFZip_maxerror_$i $LEN
    ./assembly_bonito.sh $BASECALLDIR/SZ_maxerror_$i.fastq $ASSEMBLYDIR/SZ_maxerror_$i $LEN
done

