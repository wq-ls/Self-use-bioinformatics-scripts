#!/bin/bash

source activate /micromamba/envs/sonicparanoid

cwd=$PWD
indir=./input
outdir=$PWD/result
cpu=35
prefix=fish51
inflation=2
MIN_BITSCORE=100

sonicparanoid -i $indir -o $outdir -p $prefix -t $cpu -m sensitive -I $inflation -op -bs $MIN_BITSCORE

#mv $outdir/runs/$prefix/* $outdir
#mv $outdir/ortholog_groups $outdir/$prefix

### remove tmp filei !!!!!!!!!!!!!!!!!!!!!
#rm -rf $outdir/runs $outdir/orthologs_db $outdir/alignments
