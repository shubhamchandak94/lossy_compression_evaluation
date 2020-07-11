#!/bin/bash
set -e

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters, see usage in script"
    exit 1
fi

# Usage ./basecall_assembly.sh FASTQFILENAME DIRNAME GENOME_SIZE MEDAKA_MODEL
# where FASTQFILENAME is the basecalled fastq file
# DIRNAME is the place where the assemblies are written to 
# and GENOME_SIZE is expected genome size (set to 5.5m for K.p.)
# MEDAKA_MODEL is chosen according to basecaller config
# NOTE: paths to other tools are hardcoded
# The script performs the following steps:
# 1. assembly with flye
# 2. Polishing using Racon (use rebaler that does multiple rounds)
# 3. Medaka consensus on the Racon-polished assembly

FASTQNAME=$1
DIRNAME=$2
GENOME_SIZE=$3
MEDAKA_MODEL=$4
FLYE=$WORKINGDIR/Flye-2.7.1/bin/flye
REBALER=$WORKINGDIR/Rebaler-0.2.0/rebaler-runner.py
RACON_PATH=$WORKINGDIR/racon-v1.4.13/build/bin/
MINIMAP2_PATH=$WORKINGDIR/minimap2-2.17/
MEDAKA_VENV_PATH=$WORKINGDIR/medaka_old/venv/bin/activate
LOSSY_COMP_ENV_PATH=$WORKINGDIR/lossy_comp_env/bin/activate

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
medaka_consensus -i $FASTQNAME -d $DIRNAME/rebaler.fasta -o $DIRNAME/medaka -t 12 -m $MEDAKA_MODEL

source $LOSSY_COMP_ENV_PATH # reactivate original venv
