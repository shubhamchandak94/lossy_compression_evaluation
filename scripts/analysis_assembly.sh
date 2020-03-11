# Copyright 2019 Ryan Wick (rrwick@gmail.com)
# https://github.com/rrwick/August-2019-consensus-accuracy-update

# This program is free software: you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version. This program is distributed in the hope that it
# will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should
# have received a copy of the GNU General Public License along with this program. If not, see
# <http://www.gnu.org/licenses/>.

# USAGE: ./analysis_assembly.sh ASSEMBLED_FILE REFERENCE_FILE

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters, see usage in script"
    exit 1
fi

ASSEMBLED_FILE=$1
REFERENCE_FILE=$2
SCRIPT_PATH="/raid/shubham/nanopore_lossy_compression/lossy_compression_evaluation/scripts"
MINIMAP2="/raid/shubham/nanopore_lossy_compression/minimap2-2.17/minimap2"

python3 $SCRIPT_PATH/chop_up_assembly.py $1 100000 > $ASSEMBLED_FILE.pieces.fasta
$MINIMAP2 -x asm5 -t 8 -c $REFERENCE_FILE $ASSEMBLED_FILE.pieces.fasta > $ASSEMBLED_FILE.pieces.paf
python3 $SCRIPT_PATH/read_length_identity.py $ASSEMBLED_FILE.pieces.fasta $ASSEMBLED_FILE.pieces.paf > $ASSEMBLED_FILE.pieces.data
printf $1"\t"
python3 $SCRIPT_PATH/medians.py $ASSEMBLED_FILE.pieces.data
rm $ASSEMBLED_FILE.pieces.*
