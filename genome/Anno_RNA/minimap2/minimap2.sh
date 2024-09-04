
genome=HCS_chr.fa
trans=trans.fa
cpu=40

minimap2 -ax splice:hq -uf ${genome} ${trans} -t ${cpu} > aln.sam
sam2gff.pl aln.sam > aln.sam.gff3
awk '{print $0";"}' aln.sam.gff3 | sed 's/exon/CDS/g' > aln.sam.gff3.tmp

##
export PERL5LIB=/01_software/TransDecoder-TransDecoder-v5.5.0/PerlLib:$PERL5LIB
sed 's/exon/CDS/g' aln.sam.gff3 > tmp.gff
gff2gtf_v2.pl tmp.gff aln.sam.gtf
rm tmp.gff
perl /01_software/TransDecoder-TransDecoder-v5.5.0/util/gtf_genome_to_cdna_fasta.pl aln.sam.gtf ${genome} > transcripts.fasta
/01_software/TransDecoder-TransDecoder-v5.5.0/TransDecoder.LongOrfs -m 50 -t transcripts.fasta
