#!/bin/bash
set -e

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters, see usage in script"
    exit 1
fi

# Usage ./basecall.sh FAST5DIRNAME FASTQFILENAME GUPPY_CONFIG
# FAST5DIRNAME is directory with fast5 files
# FASTQFILENAME is desired name for basecalled fastq file
# GUPPY_CONFIG is guppy config chosen based on pore version and mode
# performs basecalling with guppy
# NOTE: path to guppy is hardcoded

DIRNAME=$1
FASTQNAME=$2
GUPPYCONFIG=$3
GUPPY=$WORKINGDIR/ont-guppy/bin/guppy_basecaller

# basecall with guppy
mkdir $DIRNAME/guppy_tmp_out
$GUPPY --input_path $DIRNAME/ --device cuda:3 --config $GUPPYCONFIG --save_path $DIRNAME/guppy_tmp_out
cat $DIRNAME/guppy_tmp_out/*.fastq > $FASTQNAME
rm -r $DIRNAME/guppy_tmp_out/
