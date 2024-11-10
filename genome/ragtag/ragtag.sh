source activate /01_software/conda/envs/ragtag/

# scaffold with multiple references/maps
ragtag.py scaffold -t 48 -o out_1 chr.rename.fa polish_contig.fa
ragtag.py scaffold -t 20 -o out_2 GCF_963930695.1_fLabBer1.1_genomic.fna polish_contig.fa
ragtag.py scaffold -t 20 -o out_3 GCF_963584025.1_fLabMix1.1_genomic.fna polish_contig.fa
ragtag.py scaffold -t 20 -o out_4 GCF_009762535.1_fNotCel1.pri_genomic.fna polish_contig.fa

ragtag.py merge out_correct.fa out_*/*.agp -o Merge1
ragtag.py merge out_correct.fa out_1/*.agp  out_2/*.agp out_4/*.agp out_6/*.agp -o Merge2
ragtag.py merge --gap-func max out_correct.fa out_1/*.agp  out_2/*.agp out_4/*.agp out_6/*.agp -o Merge3

## remove other characters
# perl filter.pl ragtag.scaffold.fasta > chr.fa
