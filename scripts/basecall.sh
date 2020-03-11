#!/bin/bash
set -e

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters, see usage in script"
    exit 1
fi

# Usage ./basecall.sh FAST5DIRNAME FASTQFILENAME
# FAST5DIRNAME is directory with fast5 files
# FASTQFILENAME is desired name for basecalled fastq file
# performs basecalling with guppy
# NOTE: path to guppy is hardcoded

DIRNAME=$1
FASTQNAME=$2
GUPPY="/raid/shubham/nanopore_lossy_compression/ont-guppy/bin/guppy_basecaller"

# basecall with guppy
mkdir $DIRNAME/guppy_tmp_out
$GUPPY --input_path $DIRNAME/ --device cuda:4 --config dna_r9.4.1_450bps_hac.cfg --save_path $DIRNAME/guppy_tmp_out
cat $DIRNAME/guppy_tmp_out/*.fastq > $FASTQNAME
rm -r $DIRNAME/guppy_tmp_out/
