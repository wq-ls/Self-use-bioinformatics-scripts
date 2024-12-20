#!/bin/bash
set +o posix
set -eo pipefail

source activate /01_software/mamba/envs/biser

genome=Strongylocentrotus_purpuratus.fa
output=Strongylocentrotus_purpuratus
cpu=2
tempdir=$PWD/temp

[ -d ${tempdir} ] || mkdir ${tempdir}

## scaffold to contig and mask
bedtools maskfasta -fi ${genome} -fo mask.fa -bed HiTE.bed -mc "_"
scaffold_to_contig.pl softmask.fa > mask_contig.fa
scaffold_to_contig.pl -out contig_coor mask.fa > softmask_contig.fa.coor
seqkit replace -p "_" -r "N" -s mask_contig.fa > hardmask.fa
rm mask.fa mask_contig.fa

samtools faidx hardmask.fa
biser --gc-heap 2G --hard --threads ${cpu} --output ${output}.SD.bed --keep-contigs --keep-temp --temp ${tempdir} hardmask.fa
rm hardmask.fa HiTE.gff HiTE.bed hardmask.fa.fai
