### https://github.com/zengxiaofei/HapHiC

micromamba activate haphic

genome=corrected_asm.fa
cpu=80
nchrs=23

haphic sort ${genome} HT_links.pkl split_clms final_groups/group*.txt --processes ${cpu}
