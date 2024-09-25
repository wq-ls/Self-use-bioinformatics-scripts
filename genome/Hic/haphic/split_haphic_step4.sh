### https://github.com/zengxiaofei/HapHiC

micromamba activate haphic

raw_genome=out_correct.fa
haphic_corrected_genome=corrected_asm.fa
cpu=50
nchrs=23
gap_size=500
prefix=haphic

haphic build ${haphic_corrected_genome} ${raw_genome} HiC.filtered.bam final_tours/group*.tour --corrected_ctgs corrected_ctgs.txt --Ns ${gap_size} --prefix ${prefix}
