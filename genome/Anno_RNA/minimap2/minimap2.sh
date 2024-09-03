
genome=HCS_chr.fa
trans=trans.fa
cpu=40

minimap2 -ax splice:hq -uf ${genome} ${trans} -t ${cpu} > aln.sam
sam2gff.pl aln.sam > aln.sam.gff3
