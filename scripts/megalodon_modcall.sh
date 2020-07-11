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
   --guppy-params "-d $WORKINGDIR/rerio/basecall_models/ --num_callers 40 --cpu_threads_per_caller 30 --gpu_runners_per_device 30" \
   --guppy-config res_dna_r941_min_modbases_5mC_CpG_v001.cfg \
   --guppy-server-path=$GUPPYDIR/guppy_basecall_server \
   --guppy-timeout 30.0 \
   --mod-motif m CG 0 \
   --processes 40 \
   --device cuda:0 cuda:1 cuda:2 cuda:3 cuda:4 cuda:5 cuda:6 cuda:7 \
   --outputs per_read_mods \
   --output-directory $OUTPUTDIR \
   --reference $REF \
   --write-mods-text \
   $FAST5DIR
