export PATH=/01_software/TransDecoder-TransDecoder-v5.5.0/util/:$PATH
export PERL5LIB=/01_software/TransDecoder-TransDecoder-v5.5.0/PerlLib:$PERL5LIB

###
cat pfam.qsub/pfam.1.domtblout > pfam.domtblout
for i in `seq 2 200`
do
    less pfam.qsub/pfam.${i}.domtblout | grep -v '^#' >> pfam.domtblout
done
cat blast.qsub/*outfmt6 | awk '$3>60' > blastp.outfmt6

###
transcript=transcripts.fasta
/01_software/TransDecoder-TransDecoder-v5.5.0/TransDecoder.Predict -t ${transcript} --retain_pfam_hits pfam.domtblout --retain_blastp_hits blastp.outfmt6

gtf_to_alignment_gff3.pl ${gtf} > ${gtf}.gff3
cdna_alignment_orf_to_genome_orf.pl ${trans}.transdecoder.gff3  ${gtf}.gff3 ${trans}  > ${trans}.transdecoder.genome.gff3
awk '$3=="CDS" || $3=="mRNA" {print $0";"} ' ${trans}.transdecoder.genome.gff3 > ${trans}.transdecoder.genome.gff3.tmp
Covert_for_evm.pl ${trans}.transdecoder.genome.gff3.tmp TransDecoder | awk '!a[$1"\t"$4"\t"$5]++{print $0}' > ${trans}.transdecoder.genome.gff3.forevm.gff3
