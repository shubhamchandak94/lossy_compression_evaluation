#!/bin/bash
set -e

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters, see usage in script"
    exit 1
fi


GUPPYDIR=$WORKINGDIR/ont-guppy/bin/
FAST5DIR=$1
REF=$2
OUTPUTDIR=$3

megalodon \
   --guppy-config dna_r9.4.1_450bps_modbases_dam-dcm-cpg_hac.cfg \
   --guppy-server-path=$GUPPYDIR/guppy_basecall_server \
   --guppy-timeout 10.0 \
   --mod-motif Z CCWGG 1 \
   --mod-motif Y GATC 1 \
   --processes 20 \
   --devices 0 1 2 3 4 5 6 7 \
   --outputs mod_mappings \
   --devices 0 \
   --output-directory $OUTPUTDIR \
   --reference $REF \
   --write-mods-text \
   $FAST5DIR
