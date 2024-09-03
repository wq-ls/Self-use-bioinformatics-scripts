### https://github.com/zengxiaofei/HapHiC

micromamba activate haphic

export PATH="/01_soft/samblaster/:$PATH"
export PATH="/01_soft/HapHiC/:$PATH"
export PATH="/01_soft/HapHiC/utils/:$PATH"

genome=$PWD/YZ.keep.fa
hic1=$PWD/YZ_clean.R1.fq.gz
hic2=$PWD/YZ_clean.R2.fq.gz
cpu=20
chromosome_num=23

#bwa index ${genome}
bwa mem -5SP -t ${cpu} ${genome} ${hic1} ${hic2} | samblaster | samtools view - -@ ${cpu} -S -h -b -F 3340 -o HiC.bam
filter_bam HiC.bam 1 --nm 3 --threads ${cpu} | samtools view - -b -@ ${cpu} -o HiC.filtered.bam

# pipline
# haphic pipeline ${genome} HiC.filtered.bam ${chromosome_num} --max_inflation 10 --threads ${cpu}

# step1
haphic cluster --threads ${cpu} --max_inflation 10 ${genome} HiC.filtered.bam ${chromosome_num}

# step2
x=`grep "recommend_inflation" HapHiC_cluster.log | awk -F "inflation from" '{print $2}' | awk -F " " '{print $1}'`
haphic reassign --nclusters ${chromosome_num} --threads ${cpu} ${genome} full_links.pkl inflation_$x/mcl_inflation_$x.clusters.txt paired_links.clm

# step3
haphic sort ${genome} HT_links.pkl split_clms final_groups/group*.txt --processes ${cpu}

# step4
haphic build ${genome} ${genome} HiC.filtered.bam final_tours/group*.tour

# plot
haphic plot scaffolds.raw.agp HiC.filtered.bam
