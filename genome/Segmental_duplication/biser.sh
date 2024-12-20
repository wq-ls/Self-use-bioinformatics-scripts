#!/bin/bash
set +o posix
set -eo pipefail

source activate /01_software/mamba/envs/biser 

genome=Strongylocentrotus_purpuratus.fa
output=Strongylocentrotus_purpuratus
cpu=1
tempdir=$PWD/temp

samtools faidx hardmask.fa
biser --gc-heap 2G --hard --threads ${cpu} --output ${output}.SD.bed --keep-contigs --keep-temp --temp ${tempdir} hardmask.fa
#biser --resume ${tempdir}/biser.XXXXXXXX(change here) --gc-heap 2G --hard --threads ${cpu} --output ${output} --keep-contigs --keep-temp --no-decomposition --temp ${tempdir} hardmask.fa
rm hardmask.fa HiTE.gff HiTE.bed hardmask.fa.fai
