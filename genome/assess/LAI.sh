#!/bin/bash

#https://github.com/oushujun/LTR_retriever
#https://github.com/oushujun/LTR_FINDER_parallel/tree/v1.1
#https://github.com/oushujun/LTR_HARVEST_parallel
#https://www.jianshu.com/p/ed289822c825
#https://github.com/wangziwei08/LTR-insertion-time-estimation
#https://www.jianshu.com/p/f962d5c40fdf ### LTR_retriever

genome=hcs.chr.genome.fa
threads=20
substitution_mutations_rate=1e-8

### software path
gt_software=/01_software/gt-1.6.2-Linux_x86_64-64bit-complete/bin/gt
finder=/01_software/LTR_FINDER_parallel/bin/LTR_FINDER.x86_64-1.0.7/ltr_finder
LTR_FINDER_parallel=/01_software/LTR_FINDER_parallel/LTR_FINDER_parallel
LTR_HARVEST_parallel=/01_software/LTR_HARVEST_parallel/LTR_HARVEST_parallel

## step1 LTR_HARVEST
perl ${LTR_HARVEST_parallel} -seq ${genome} -gt ${gt_software} -threads ${threads}

## step2 LTR_FINDER
perl ${LTR_FINDER_parallel} -seq ${genome} -harvest_out -finder ${finder} -t ${threads}

## step3 LTR_retriever
source activate /01_soft/mamba/envs/LTR_retriever
LTR_retriever -genome ${genome} -inharvest ${genome}.harvest.combine.scn -infinder ${genome}.finder.combine.scn -threads ${threads} -u ${substitution_mutations_rate}

## step4 prepare draw files
sed '1d' ${genome}.pass.list | awk -F "[:\t]" '{print $1","$(NF-2)","$NF}' | sed 's/-0/0/g' > LTR_time.csv


<<draw.R
library("ggplot2")
#读入文件
dat<-read.csv("LTR_time.csv",header=FALSE)
#除以100万
VAF<-dat$V3 / 1000000

#画图（出图结果中x轴是以mya（百万年）为单位的。）
ggplot(dat,aes(x=VAF))+geom_density(color = "red")+xlab('Mya')+ylab('Density')+
  scale_x_continuous(expand = c(0, 0)) +
  #scale_y_continuous(expand = c(0, 0))+ #设置横纵坐标从0开始
  theme_classic()
ggsave('Speies.LTR.density.pdf',dpi = 300)
draw.R
