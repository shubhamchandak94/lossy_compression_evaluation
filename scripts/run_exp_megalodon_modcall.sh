#!/bin/bash

ROOTDIR=$WORKINGDIR/data/NA12878/
FASTAFILE=$ROOTDIR/Homo_sapiens.GRCh38.dna.primary_assembly.fa
OUTDIR=$ROOTDIR/experiments/megalodon_output/
TMPDIR=$OUTDIR/tmp

mkdir -p $OUTDIR
rm -rf $TMPDIR

# lossless
./megalodon_modcall.sh $ROOTDIR/fast5/ $FASTAFILE $TMPDIR
mv $TMPDIR/per_read_modified_base_calls.txt $OUTDIR/lossless.per_read_modified_base_calls.txt
rm -r $TMPDIR

# lossy
for i in {1..10}; do
    ./megalodon_modcall.sh $ROOTDIR/experiments/new_fast5/LFZip_maxerror_$i $FASTAFILE $TMPDIR
    mv $TMPDIR/per_read_modified_base_calls.txt $OUTDIR/LFZip_maxerror_$i.per_read_modified_base_calls.txt
    rm -r $TMPDIR
    ./megalodon_modcall.sh $ROOTDIR/experiments/new_fast5/SZ_maxerror_$i $FASTAFILE $TMPDIR
    mv $TMPDIR/per_read_modified_base_calls.txt $OUTDIR/SZ_maxerror_$i.per_read_modified_base_calls.txt
    rm -r $TMPDIR
done
