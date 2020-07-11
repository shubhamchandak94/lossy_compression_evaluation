#!/bin/bash
set -e

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters, see usage in script"
    exit 1
fi

# Usage ./subsample_fastqs.sh INFASTQDIRNAME OUTFASTQDIRNAME NUMREADS
# INFASTQDIRNAME is directory with original fastq files
# OUTFASTQDIRNAME is directory to put subsampled fastq
# NUMREADS is number of reads in subsampled fastq
# subsamples all fastq reads in INFASTQDIRNAME, writing to OUTFASTQDIRNAME
# NOTE: path to seqtk is hardcoded

INDIRNAME=$1
OUTDIRNAME=$2
NUMREADS=$3
SEQTK=$WORKINGDIR/seqtk-1.3/seqtk

mkdir -p $OUTDIRNAME
for f in $INDIRNAME/*.fastq; do
    filename=$(basename $f)
    $SEQTK sample -s100 $INDIRNAME/$filename $NUMREADS > $OUTDIRNAME/$filename
done
