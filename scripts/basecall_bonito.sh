#!/bin/bash
set -e

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters, see usage in script"
    exit 1
fi

# Usage ./basecall_bonito.sh FAST5DIRNAME FASTQFILENAME
# FAST5DIRNAME is directory with fast5 files
# FASTQFILENAME is desired name for basecalled fastq file
# performs basecalling with bonito
# NOTE: paths to bonito and seqtk are hardcoded

DIRNAME=$1
FASTQNAME=$2
BONITO_PATH="/raid/shubham/nanopore_lossy_compression/bonito/"
SEQTK="/raid/shubham/nanopore_lossy_compression/seqtk/seqtk"

# basecall with bonito
source $BONITO_PATH/env/bin/activate
bonito basecaller --half --device cuda:4 dna_r9.4.1 $DIRNAME > $FASTQNAME.tmp.fasta
deactivate

# convert fasta to fastq by filling in fake quality values
$SEQTK seq  -F '#' $FASTQNAME.tmp.fasta > $FASTQNAME
rm $FASTQNAME.tmp.fasta
