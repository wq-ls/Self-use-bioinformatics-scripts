### https://github.com/zengxiaofei/HapHiC

micromamba activate haphic

genome=corrected_asm.fa
cpu=80
nchrs=23
best_inflation=1.5
ambiguous_cutoff=0.4
remove_allelic_links=2

haphic reassign --ambiguous_cutoff ${ambiguous_cutoff} --remove_allelic_links ${remove_allelic_links} --nclusters ${nchrs} --threads ${cpu} ${genome} full_links.pkl inflation_${best_inflation}/mcl_inflation_${best_inflation}.clusters.txt paired_links.clm
