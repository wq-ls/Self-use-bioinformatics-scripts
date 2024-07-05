#!/bin/bash
set +o posix
set -eo pipefail

species=Branchiostoma_floridae
genome=GCF_000003815.2_Bfl_VNyyK_genomic.fna
pep=GCF_000003815.2_Bfl_VNyyK_protein.faa
gff=GCF_000003815.2_Bfl_VNyyK_genomic.gff

pick_longest_ncbi.pl ${gff}

awk -F "Dbxref" '{print $1}' clean.gff | sed 's/rna-//g;s/cds-//g;s/gene-//g' | awk '$3=="CDS"' | cut -f 9 | awk '!a[$0]++' | sed 's/ID=//g;s/;Parent=/\t/g;s/;//g' | awk -F "\t" 'NR==FNR{a[$1]=$2}NR!=FNR{print $0"\t"a[$1]}' <(grep '>' ${pep} | sed 's/>//g' | awk -F "[" '{print $1}' | sed 's/ $//g' | sed 's/ /\t/1') - | awk '{print $2"\t"$0}' | awk -F "\t" 'NR==FNR{a[$1]=$2}NR!=FNR{print $0"\t"a[$1]}' <(awk -F "Dbxref" '{print $1}' clean.gff | sed 's/rna-//g;s/cds-//g;s/gene-//g' | awk '$3=="mRNA"' | cut -f 9 | sed 's/ID=//g;s/;Parent=/\t/g;s/;//g') - | cut -f 2- | awk -F "\t" '{print $1"\t"$2"\t"$4"\t"$3}' > ${species}.ncbi.anno

awk -F "Dbxref" '{print $1}' clean.gff | sed 's/rna-//g;s/cds-//g;s/gene-//g' | awk -F ";" '{print $1";"}' | awk '{print $9"\t"$0}' | sed 's/ID=//1;s/;//1' | awk -F "\t" 'NR==FNR{a[$1]=$2}NR!=FNR{print $0"\t"a[$1]}' <(awk -F "\t" '{print $2"\t"$1}' ${species}.ncbi.anno | sed 's/\t/\tID=/g' ) - | cut -f 2- | sed 's/ID=/Parent=/1;s/\t$//g' | awk -F "\t" '{if ($3~/mRNA/) print $0";"; else print $0"\t"$9}' | cut -f 1-8,10 > clean.deal.gff

fix_mRNA_coordinate.pl clean.deal.gff clean.deal.fix.gff

gff3_sort -g clean.deal.fix.gff | grep -v "#" > ${species}.bgi.gff

gffread ${species}.bgi.gff -g ${genome} -x ${species}.bgi.gff.cds
seqkit translate --trim --clean ${species}.bgi.gff.cds > ${species}.bgi.gff.pep
grep ">" ${species}.bgi.gff.cds | awk '{print $1}' | sed "s/>//g" | seqtk subseq ${pep} - | awk '{print $1}' | seqkit seq -w 0 > ${species}.bgi.gff.pep2

rm clean*gff
