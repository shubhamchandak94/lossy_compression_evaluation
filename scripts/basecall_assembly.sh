#!/bin/bash
set -e

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters, see usage in script"
fi

# Usage ./basecall_assembly.sh DIRNAME GENOME_SIZE
# where DIRNAME contains a fast5/ dir with the relevant fast5 files
# and GENOME_SIZE is expected genome size (set to 5.5m for K.p.)
# NOTE: paths to other tools are hardcoded
# The script performs the following steps:
# 1. basecalling with guppy to DIRNAME/basecall.fastq
# 2. assembly with flye
# 3. Polishing using Racon (use rebaler that does multiple rounds)
# 4. Medaka consensus on the Racon-polished assembly

DIRNAME=$1
GENOME_SIZE=$2
GUPPY="/raid/shubham/nanopore_lossy_compression/ont-guppy/bin/guppy_basecaller"
FLYE="/raid/shubham/nanopore_lossy_compression/Flye/bin/flye"
REBALER="/raid/shubham/nanopore_lossy_compression/Rebaler/rebaler-runner.py"
RACON_PATH="/raid/shubham/nanopore_lossy_compression/racon/build/bin/"
MINIMAP2_PATH="/raid/shubham/nanopore_lossy_compression/minimap2-2.17/"
MEDAKA_VENV_PATH="/raid/shubham/nanopore_lossy_compression/medaka/venv/bin/activate"

# 1. basecall with guppy
mkdir $DIRNAME/guppy_tmp_out
$GUPPY --input_path $DIRNAME/fast5 --device cuda:4 --config dna_r9.4.1_450bps_hac.cfg --save_path $DIRNAME/guppy_tmp_out
cat $DIRNAME/guppy_tmp_out/*.fastq > $DIRNAME/basecall.fastq
rm -r $DIRNAME/guppy_tmp_out/

# 2. assembly with flye
mkdir $DIRNAME/flye/
$FLYE --nano-raw $DIRNAME/basecall.fastq --genome-size $GENOME_SIZE --out-dir $DIRNAME/flye/ --threads 12

# 3. polishing with rebaler
# add racon and minimap2 to PATH
PATH=$PATH:$RACON_PATH
PATH=$PATH:$MINIMAP2_PATH
$REBALER --threads 8 $DIRNAME/flye/assembly.fasta $DIRNAME/basecall.fastq > $DIRNAME/rebaler.fasta

# 4. medaka consensus
# first go into virtual environment
source $MEDAKA_VENV_PATH
medaka_consensus -i $DIRNAME/basecall.fastq -d $DIRNAME/rebaler.fasta -o $DIRNAME/medaka -t 12 -m r941_min_high_g344
deactivate
