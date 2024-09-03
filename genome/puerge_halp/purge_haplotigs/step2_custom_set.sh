#!/bin/bash
#https://blog.csdn.net/u012110870/article/details/100171429

micromamba activate purge_haplotigs

genome=YZ_CRAQ.fa
input=hifi_aln_sorted.bam.200.gencov
low_cut=0
mid_cut=90
high_cut=200
cpu=70

purge_haplotigs contigcov -i ${input} -o coverage_stats.csv  -l ${low_cut}  -m ${mid_cut} -h ${high_cut}
purge_haplotigs purge -g ${genome} -c coverage_stats.csv -b hifi_aln_sorted.bam -t $cpu -a 60 -v -d
