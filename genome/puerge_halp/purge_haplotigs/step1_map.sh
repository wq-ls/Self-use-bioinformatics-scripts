#!/bin/bash

#source activate home_micromamba/envs/purge_haplotigs/

genome=YZ_CRAQ.fa
ccs_fa=yz.fasta.gz
cpu=70

minimap2 -ax map-hifi -t $cpu $genome $ccs_fa --secondary=no -o hifi_aln.sam
samtools faidx ${genome}
samtools view -@ $cpu -t ${genome}.fai -bS hifi_aln.sam -o hifi_aln.bam
samtools sort -t $cpu hifi_aln.bam > hifi_aln_sorted.bam
rm hifi_aln.sam hifi_aln.bam

purge_haplotigs readhist -b hifi_aln_sorted.bam -g $genome -t ${cpu}
