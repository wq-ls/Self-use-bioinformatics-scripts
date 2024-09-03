
genome=HCS_chr.fa
trans=trans.fa
cpu=40

minimap2 -ax splice:hq -uf ${genome} ${trans} -t ${cpu} > aln.sam
sam2gff.pl aln.sam > aln.sam.gff3
awk '{print $0";"}' aln.sam.gff3 | sed 's/exon/CDS/g' > aln.sam.gff3.tmp
Covert_for_evm.pl aln.sam.gff3.tmp minimap | awk '!a[$1"\t"$4"\t"$5]++{print $0}' > aln.sam.gff3.forevm.gff3

# rm aln.sam.gff3.tmp aln.sam
