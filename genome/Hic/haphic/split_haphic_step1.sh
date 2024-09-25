### https://github.com/zengxiaofei/HapHiC

micromamba activate haphic

genome=out_correct.fa
cpu=80
nchrs=23
inflation_step=0.1
min_inflation=1
max_inflation=1.5

haphic cluster --remove_concentrated_links --remove_allelic_links 2 --threads ${cpu} --correct_nrounds 2 --correct_resolution 250 ${genome} HiC.filtered.bam ${nchrs} --inflation_step ${inflation_step} --min_inflation ${min_inflation}  --max_inflation ${max_inflation}
