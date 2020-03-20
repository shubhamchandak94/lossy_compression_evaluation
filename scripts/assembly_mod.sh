#!/bin/bash
set -e

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters, see usage in script"
    exit 1
fi

# Usage ./basecall_assembly.sh FASTQFILENAME DIRNAME GENOME_SIZE
# where FASTQFILENAME is the basecalled fastq file
# DIRNAME is the place where the assemblies are written to 
# and GENOME_SIZE is expected genome size (set to 5.5m for K.p.)
# NOTE: paths to other tools are hardcoded
# The script performs the following steps:
# 1. assembly with flye
# 2. Polishing using Racon (use rebaler that does multiple rounds)
# 3. Medaka consensus on the Racon-polished assembly

FASTQNAME=$1
DIRNAME=$2
GENOME_SIZE=$3
FLYE="/raid/shubham/nanopore_lossy_compression/Flye/bin/flye"
REBALER="/raid/shubham/nanopore_lossy_compression/Rebaler/rebaler-runner.py"
RACON_PATH="/raid/shubham/nanopore_lossy_compression/racon/build/bin/"
MINIMAP2_PATH="/raid/shubham/nanopore_lossy_compression/minimap2-2.17/"
MEDAKA_VENV_PATH="/raid/shubham/nanopore_lossy_compression/medaka/venv/bin/activate"

# create DIRNAME if doesn't already exist
mkdir -p $DIRNAME

# 1. assembly with flye
mkdir $DIRNAME/flye/
$FLYE --nano-raw $FASTQNAME --genome-size $GENOME_SIZE --out-dir $DIRNAME/flye/ --threads 12

# 2. polishing with rebaler
# add racon and minimap2 to PATH
PATH=$PATH:$RACON_PATH
PATH=$PATH:$MINIMAP2_PATH
$REBALER --threads 8 $DIRNAME/flye/assembly.fasta $FASTQNAME > $DIRNAME/rebaler.fasta

# 3. medaka consensus
# first go into virtual environment
source $MEDAKA_VENV_PATH
medaka_consensus -i $FASTQNAME -d $DIRNAME/rebaler.fasta -o $DIRNAME/medaka -t 12 -m r941_min_high_g344
deactivate
