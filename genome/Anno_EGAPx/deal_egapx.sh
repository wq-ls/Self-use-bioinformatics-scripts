#!/bin/bash
set +o posix

species=C_nasu
egapx_gff=complete.genomic.gff
pep=complete.proteins.faa
cds=complete.cds.fna

## deal feature
[ -d stat_feature ] || mkdir stat_feature
grep "pseudo=true" ${egapx_gff} | awk '$3=="pseudogene"' | cut -f 1,4,5,7,9 | sed 's/;/\t/g' | sed 's/ID=gene-//1;s/Name=//1;s/description=//1' | cut -f 1-5,7 > stat_feature/pseudogene.txt
grep "gene_biotype=lncRNA" ${egapx_gff} | cut -f 1,4,5,7,9 | sed 's/;/\t/g' | cut -f 1-5 | sed 's/ID=gene-//g' > stat_feature/lncRNA.txt
grep "gene_biotype=V_segment" ${egapx_gff} | cut -f 1,4,5,7,9 | sed 's/;/\t/g' | sed 's/ID=gene-//1;s/Name=//1;s/description=//1' | cut -f 1-5,7 > stat_feature/V_segment.txt
grep "gene_biotype=C_region" ${egapx_gff} | cut -f 1,4,5,7,9 | sed 's/;/\t/g' | sed 's/ID=gene-//1;s/Name=//1;s/description=//1' | cut -f 1-5,7 > stat_feature/C_region.txt
grep misc_RNA ${egapx_gff} | awk '$3=="transcript"' | cut -f 1,4,5,7,9 | sed 's/;/\t/g' | sed 's/ID=//1' > stat_feature/misc.txt
cat stat_feature/*txt | cut -f 5 | awk '!a[$0]++' | sed '/^s*$/d' | grep -v -f - ${egapx_gff} | awk '$3=="gene"' | cut -f 1,4,5,7,9 | sed 's/;/\t/g' | awk -F "\t" '{if ($7~/description/) print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7; else if ($8~/description/) print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$7"\t"$8; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$5"\tuncharacterized protein" }' | sed 's/ID=gene-//g;s/Name=//g;s/description=//g' > stat_feature/protein.txt

## get longest and contain UTR gff file
cut -f 5 stat_feature/protein.txt | grep -f - ${egapx_gff} | grep -v -e "pseudo=true" -e "gene_biotype=lncRNA" -e "gene_biotype=V_segment" -e "gene_biotype=C_region" -e "gbkey=ncRNA" -e "misc_RNA" > pep.gff
/usr/bin/singularity run --bind $PWD:$PWD /dellfsqd2/ST_OCEAN/USER/lishuo11/01_soft/singularity_all/Agata.sif agat_sp_keep_longest_isoform.pl -gff pep.gff -o ${species}.UTR.gff
rm pep.gff pep.agat.log

## get simple gff cds pep
toBGI.py ${species}.UTR.gff > bgi.gff
sed 's/|/\t/g' bgi.gff | awk '{print $NF"\t"$0}' | sed 's/-R/-P/1' | awk '{if ($4=="mRNA") print $2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\tID="$1; else print $2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\tParent="$1}' > bgi.rename.gff
fix_mRNA_coordinate.pl bgi.rename.gff bgi.fix.gff
fix_phase.py bgi.fix.gff
nr_gff.pl --direction F mrna_bgi.fix.gff
mv mrna_bgi.fix.gff.nr.gff ${species}.bgi.gff
awk '{print $1}' ${pep} | sed 's/|/\t/g' | awk '{if ($1~/>/) print ">"$NF; else print $0}' > ${pep}.deal
seqkit seq -w 0 ${cds} | sed 's/protein_id=/\t/g' | awk -F "\t" '{if ($1~/>/) print ">"$2; else print $0}' | sed 's/\]/\t/g' | awk '{print $1}' > ${cds}.deal
awk '$3=="mRNA"' ${species}.bgi.gff | cut -f 9 | sed 's/ID=//g;s/;//g' | seqtk subseq ${pep}.deal - | awk '{print $1}' > ${species}.bgi.gff.pep
awk '$3=="mRNA"' ${species}.bgi.gff | cut -f 9 | sed 's/ID=//g;s/;//g' | seqtk subseq ${cds}.deal - | awk '{print $1}' > ${species}.bgi.gff.cds
rm bgi.gff bgi.gff bgi.fix.gff mrna_bgi.fix.gff mrna_bgi.fix.gff.cluster mrna_bgi.fix.gff.uncluster ${cds}.deal ${pep}.deal bgi.rename.gff

## get anno from egapx
grep ">" ${pep} | sed 's/|/\t/g' | cut -f 3- | sed 's/ /\t/1' > stat_feature/egapx.anno.txt
diamond makedb --in ${pep} -d complete.proteins
diamond blastp --db complete.proteins --query ${species}.bgi.gff.pep --out result.txt --outfmt 6 qseqid qstart qend sseqid sstart send qlen slen length pident evalue --more-sensitive --max-target-seqs 5 --evalue 1e-3 --id 50 --tmpdir ./ --threads 10
awk '$10=="100"' result.txt | awk '!a[$1]++{print $0}' | awk '{print $4"\t"$1}' | sed 's/|/\t/g' | awk '{print $(NF-1)"\t"$NF}' | awk 'NR==FNR{a[$1]=$0}NR!=FNR{print $0"\t"a[$1]}' stat_feature/egapx.anno.txt - | cut -f 2,4 > egapx.anno.tsv
rm result.txt complete.proteins.dmnd
