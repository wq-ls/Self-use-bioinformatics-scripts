#!/bin/bash
set +o posix
set -eo pipefail

protein=use.pep
cds=use.cds
genome=HCS.fa
output_prefix=hcs
cpu=48

## find candicate region
miniprot -t ${cpu} --gff -P ${output_prefix} ${genome} ${protein} --outs=0.6 > miniprot.gff

## make bed of candicate region and flank 100k
samtools faidx ${genome}
cut -f 1,2 ${genome}.fai | sort -k 1,1 > ${genome}.genome.size
awk '$3=="mRNA"' miniprot.gff | cut -f 1,4,5 | sort -k 1,1 -k 2n,2 | bedtools flank -i - -g ${genome}.genome.size -b 100000 | sort -k 1,1 -k 2n,2 | bedtools merge -i - | sort -k 1,1 -k 2n,2 | bedtools complement -i - -g ${genome}.genome.size | sort -k 1,1 -k 2n,2 > miniprot.flank_100k.complement.bed

## mask genome
bedtools maskfasta -fi ${genome} -fo ${genome}.mask.fa -bed miniprot.flank_100k.complement.bed

## split genome
cut -f 1 miniprot.gff | grep -v "#" | awk '!a[$0]++' | seqtk subseq ${genome}.mask.fa - | seqkit seq -w 60 > ${genome}.mask.for_anno.fa
rm ${genome}.fai ${genome}.mask.fa
fastaDeal.pl --cuts 1 ${genome}.mask.for_anno.fa
ls ${genome}.mask.for_anno.fa.cut/ > chr.id

## remove tmp
rm ${genome}.fai ${genome}.mask.fa miniprot.flank_100k.complement.bed ${genome}.genome.size ${genome}.mask.for_anno.fa
pigz --best miniprot.gff
