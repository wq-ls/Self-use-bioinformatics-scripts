##https://github.com/yeeus/GCI

genome=curated.fasta
threads=70
pb_ccs_fq=ccs.fq.gz
kmer=17

## Map HiFi and/or ONT reads to assemblies
minimap2 -t $threads -ax map-hifi $genome $pb_ccs_fq > align.sam   ## mapping ONT reads with -ax map-ont
samtools view -@ $threads -Sb align.sam | samtools sort -@ $threads -o align.bam
samtools index align.bam
rm align.sam

/01_soft/meryl-1.4.1/bin/meryl count k=${kmer} output merylDB ${genome}
/01_soft/meryl-1.4.1/bin/meryl print greater-than distinct=0.9998 merylDB > mat_repetitive_k${kmer}.txt
/01_soft/Winnowmap/bin/winnowmap -k ${kmer} -W mat_repetitive_k${kmer}.txt -ax map-pb $genome $pb_ccs_fq > align2.sam
samtools view -@ $threads -Sb align2.sam | samtools sort -@ $threads -o align2.bam
samtools index align2.bam
rm align2.sam

# We recommend to input one bam and one paf file produced by two softwares (for example, one bam file from winnowmap and one paf file from minimap2)
# PDF is recommended because PNG file may lose some details though GCI will output png files by default
/01_soft/GCI/GCI.py -r ${genome} --hifi align.bam align2.bam -t $threads -p -it pdf
