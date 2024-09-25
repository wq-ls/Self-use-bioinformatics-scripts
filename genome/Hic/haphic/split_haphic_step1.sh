### https://github.com/zengxiaofei/HapHiC

micromamba activate haphic

genome=out_correct.fa
cpu=80
nchrs=23

haphic cluster --remove_concentrated_links --remove_allelic_links 2 --threads ${cpu} --correct_nrounds 2 --correct_resolution 250 ${genome} HiC.filtered.bam ${nchrs}
