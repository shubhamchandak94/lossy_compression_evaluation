#!/bin/bash

# USAGE: ./run_exp_assembly_analysis.sh ASSEMBLY_DIR NUM_EXP REFERENCE_FILE
# ASSEMBLY_DIR: directory with assembly subdirectories (lossless, LFZip_maxerror_i, SZ_maxerror_i)
# NUM_EXP: number of maxerror experiments, e.g., 10 for LFZip_maxerror_1 to LFZip_maxerror_10
# REFERENCE_FILE: reference assembly for comparison
# writes results to $ASSEMBLY_DIR/summary.tsv

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters, see usage in script"
    exit 1
fi

ASSEMBLY_DIR=$1
NUM_EXP=$2
REFERENCE_FILE=$3
OUTFILE=$ASSEMBLY_DIR/summary.tsv
printf "Assembly\tnum_contigs\ttotal_length\tidentity\t4mer_acc\t5mer_acc\t6mer_acc\t7mer_acc\t8mer_acc\t9mer_acc\n" > $OUTFILE


# assembly
./analysis_assembly.sh $ASSEMBLY_DIR/lossless/flye/assembly.fasta $REFERENCE_FILE lossless_flye >> $OUTFILE
./analysis_assembly.sh $ASSEMBLY_DIR/lossless/rebaler.fasta $REFERENCE_FILE lossless_rebaler >> $OUTFILE
./analysis_assembly.sh $ASSEMBLY_DIR/lossless/medaka/consensus.fasta $REFERENCE_FILE lossless_medaka >> $OUTFILE

for i in $(seq 1 $NUM_EXP); do
    ./analysis_assembly.sh $ASSEMBLY_DIR/LFZip_maxerror_$i/flye/assembly.fasta $REFERENCE_FILE LFZip_maxerror_$i"_flye" >> $OUTFILE
    ./analysis_assembly.sh $ASSEMBLY_DIR/LFZip_maxerror_$i/rebaler.fasta $REFERENCE_FILE LFZip_maxerror_$i"_rebaler" >> $OUTFILE
    ./analysis_assembly.sh $ASSEMBLY_DIR/LFZip_maxerror_$i/medaka/consensus.fasta $REFERENCE_FILE LFZip_maxerror_$i"_medaka" >> $OUTFILE
    ./analysis_assembly.sh $ASSEMBLY_DIR/SZ_maxerror_$i/flye/assembly.fasta $REFERENCE_FILE SZ_maxerror_$i"_flye" >> $OUTFILE
    ./analysis_assembly.sh $ASSEMBLY_DIR/SZ_maxerror_$i/rebaler.fasta $REFERENCE_FILE SZ_maxerror_$i"_rebaler" >> $OUTFILE
    ./analysis_assembly.sh $ASSEMBLY_DIR/SZ_maxerror_$i/medaka/consensus.fasta $REFERENCE_FILE SZ_maxerror_$i"_medaka" >> $OUTFILE
done

