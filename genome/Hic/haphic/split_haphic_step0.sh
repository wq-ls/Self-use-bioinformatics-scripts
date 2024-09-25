### https://github.com/zengxiaofei/HapHiC

micromamba activate haphic

genome=merge.hap.fa
cpu=70
nchrs=23

# HapHiC will ignore the parameter "nchrs", it can be any integer
 haphic pipeline ${genome} HiC.filtered.bam ${nchrs} --quick_view

# Correct input contigs before a quick view
#haphic pipeline ${genome} HiC.filtered.bam ${nchrs} --quick_view --correct_nrounds 2

# Partition contigs into different haplotypes in quick view mode
# haphic pipeline ${genome} HiC.filtered.bam ${nchrs} --quick_view --gfa "XXX.hap1.p_ctg.gfa,XXX.hap2.p_ctg.gfa" --correct_nrounds 2
