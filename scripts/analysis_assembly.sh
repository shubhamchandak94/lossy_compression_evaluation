# Copyright 2019 Ryan Wick (rrwick@gmail.com)
# https://github.com/rrwick/August-2019-consensus-accuracy-update

# This program is free software: you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version. This program is distributed in the hope that it
# will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should
# have received a copy of the GNU General Public License along with this program. If not, see
# <http://www.gnu.org/licenses/>.

# USAGE: ./analysis_assembly.sh ASSEMBLED_FILE REFERENCE_FILE LABEL
# LABEL is the first column of the output produced by this (e.g., lossless or SZ_maxerror_10)
# Output to stdout (tab-delimited): LABEL NUM_CONTIGS TOTAL_LENGTH MEDIAN_IDENTITY

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters, see usage in script"
    exit 1
fi

ASSEMBLED_FILE=$1
REFERENCE_FILE=$2
LABEL=$3
SCRIPT_PATH=$WORKINGDIR/lossy_compression_evaluation/scripts
MINIMAP2_PATH=$WORKINGDIR/minimap2-2.17/
SAMTOOLS_PATH=$WORKINGDIR/samtools-1.10/

export PATH=$PATH:$MINIMAP2_PATH:$SAMTOOLS_PATH

python3 $SCRIPT_PATH/chop_up_assembly.py $1 100000 > $ASSEMBLED_FILE.pieces.fasta
minimap2 -x asm5 -t 8 -c $REFERENCE_FILE $ASSEMBLED_FILE.pieces.fasta > $ASSEMBLED_FILE.pieces.paf
python3 $SCRIPT_PATH/read_length_identity.py $ASSEMBLED_FILE.pieces.fasta $ASSEMBLED_FILE.pieces.paf > $ASSEMBLED_FILE.pieces.data
printf $3"\t"

awk '
BEGIN {
    num_contigs=0
    total_len=0
}
{
    if ($0 ~ /^>/)
        num_contigs+=1;
    else
        total_len+=length($0);
}
END {
    printf num_contigs"\t"
    printf total_len"\t"
}' $ASSEMBLED_FILE
python3 $SCRIPT_PATH/medians.py $ASSEMBLED_FILE.pieces.data | tr -d '\n'
rm $ASSEMBLED_FILE.pieces.*
printf "\t"
python $WORKINGDIR/assembly_accuracy/fastmer.py --reference $REFERENCE_FILE --assembly $ASSEMBLED_FILE | tail -n 1 | cut -f 9-

