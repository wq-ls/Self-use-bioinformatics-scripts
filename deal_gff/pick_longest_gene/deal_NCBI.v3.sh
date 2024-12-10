#!/bin/bash
set +o posix

## test data get from https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/972/845/GCF_000972845.2_L_crocea_2.0/
species=O_nilo
NCBI_gff=GCF_000972845.2_L_crocea_2.0_genomic.gff
pep=GCF_000972845.2_L_crocea_2.0_protein.faa
cds=GCF_000972845.2_L_crocea_2.0_cds_from_genomic.fna
feature=GCF_001858045.2_O_niloticus_UMD_NMBU_feature_table.txt
gaf=GCF_001858045.2_O_niloticus_UMD_NMBU_gene_ontology.gaf

## get longest and contain UTR gff file
grep -e "gene_biotype=protein_coding" -e "gbkey=mRNA;gene" -e "protein_id=" ${NCBI_gff} > pep.gff
##### https://github.com/NBISweden/AGAT ######
/usr/bin/singularity run --bind $PWD:$PWD /01_soft/singularity_all/Agat.sif agat_sp_keep_longest_isoform.pl -gff pep.gff -o ${species}.UTR.gff
rm pep.gff pep.agat.log

## get Gene XP XM symbol description
awk '$3=="gene"' ${species}.UTR.gff | cut -f 9 | sed 's/;/\t/g' | sed 's/ID=gene-//1;s/Dbxref=GeneID://1;s/Name=//1' | cut -f 2,3 > geneID_name
awk '$3=="CDS"' ${species}.UTR.gff | cut -f 9 | sed 's/;/\t/g' | sed 's/ID=cds-//1;s/Parent=rna-//1' | sed 's/,/\t/1' | awk '{if ($3~/GeneID/) print $3"\t"$1"\t"$2; else print $4"\t"$1"\t"$2}' | sed 's/Dbxref=GeneID://g' | sed 's/GeneID://g' | awk -F "\t" 'NR==FNR{a[$1]=$2}NR!=FNR{print $0"\t"a[$1]}' geneID_name - | awk '!a[$0]++' > tmp1
awk '{print $2"\t"$0}' tmp1 | awk -F "\t" 'NR==FNR{a[$1]=$2}NR!=FNR{print $0"\t"a[$1]}' <(grep ">" ${pep} | sed 's/>//1;s/ /\t/1;s/\[/\t/1' | cut -f 1,2) - | cut -f 2- > NCBI.gene.match.txt
sed 's/ /||||||||/g' NCBI.gene.match.txt | csvtk -t add-header -n GeneID,pepID,rnaID,Symbol,description | csvtk join -t --left-join --na NA - <(sed 's/\!\#DB/DB/g' ${gaf} | grep -v "^\!" | cut -f 2-) | sed 's/||||||||/ /g' > NCBI.gene.match.more.txt
rm tmp1 geneID_name

## get simple gff cds pep
toBGI.py ${species}.UTR.gff > bgi.gff
awk '{print $9"\t"$0}' bgi.gff | sed 's/Parent=rna-//1;s/;//1;s/ID=rna-//1' | awk -F "\t" 'NR==FNR{a[$1]=$2}NR!=FNR{print $0"\t"a[$1]}' <( awk '{print $3"\t"$2}' NCBI.gene.match.txt) - | cut -f 2- | awk -F "\t" '{if ($3~/mRNA/) print $0"\tID="$NF";"; else print $0"\tParent="$NF";";}' | cut -f 1-8,11 > bgi2.gff
fix_mRNA_coordinate.pl bgi2.gff bgi2.fix.gff
fix_phase.py bgi2.fix.gff
nr_gff.pl --direction F mrna_bgi2.fix.gff
mv mrna_bgi2.fix.gff.nr.gff ${species}.bgi.gff
awk '$3=="mRNA"' ${species}.bgi.gff | cut -f 9 | sed 's/ID=//g;s/;//g' | seqtk subseq ${pep} - | awk '{print $1}' > ${species}.bgi.gff.pep
seqkit seq -w 0 ${cds} | sed 's/_cds_/\t/1' | awk '{if ($1~/>/) print ">"$2; else print $0}' | sed 's/_/ /2' | awk '{print $1}' > ${cds}.deal
awk '$3=="mRNA"' ${species}.bgi.gff | cut -f 9 | sed 's/ID=//g;s/;//g' | seqtk subseq ${cds}.deal - | awk '{print $1}' > ${species}.bgi.gff.cds
rm bgi.gff bgi2.gff bgi2.fix.gff mrna_bgi2.fix.gff mrna_bgi2.fix.gff.cluster mrna_bgi2.fix.gff.uncluster ${cds}.deal

## deal feature
[ -d stat_feature ] || mkdir stat_feature
awk '$1=="gene" || $1=="feature"' ${feature} | cut -f 2,7,8,9,10,15,16 | csvtk -t cut -f 2-,1 > stat_feature/gene.txt
awk '$1=="ncRNA" || $1=="feature"' ${feature} | cut -f 2,7,8,9,10,11,14,16 | csvtk -t cut -f 2-,1 | csvtk sort -t -k 8 -k 1 -k 2:n > stat_feature/ncRNA.txt
awk '$1=="tRNA" || $1=="feature"' ${feature} | cut -f 7,8,9,10,14,15,16,20 > stat_feature/tRNA.txt
awk '$1=="mRNA" || $1=="feature"' ${feature} | cut -f 7,8,9,10,11,13,14,15,16 > stat_feature/mRNA.txt
awk '$1=="CDS" || $1=="feature"' ${feature} | grep -e without_protein -e feature | cut -f 7,8,9,10,14,15,16 > stat_feature/protein_without.txt
awk '$1=="CDS" || $1=="feature"' ${feature} | grep -v without_protein | cut -f 7,8,9,10,11,13,14,15,16 > stat_feature/protein.txt
awk '$1=="C_region" || $1=="feature"' ${feature} | cut -f 7,8,9,10,15,16 > stat_feature/C_region.txt
awk '$1=="V_segment" || $1=="feature"' ${feature} | cut -f 7,8,9,10,15,16 > stat_feature/V_segment.txt
awk '$1=="misc_RNA" || $1=="feature"' ${feature} | cut -f 7,8,9,10,11,14,15,16 > stat_feature/misc_RNA.txt
awk '$1=="rRNA" || $1=="feature"' ${feature} | cut -f 7,8,9,10,11,14,15,16 > stat_feature/rRNA.txt
