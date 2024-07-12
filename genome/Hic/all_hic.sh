all_hic主要针对于多倍体以及高杂合度基因组进行挂载hic，以下方法是利用all_hic对二倍体简单基因组进行挂载（针对于复杂基因组之后有空进行补充）
1、下载all_hic软件
-------------------------------------------------
$ git clone https://github.com/tangerzhang/ALLHiC
$ cd ALLHiC
$ chmod +x bin/*
$ chmod +x scripts/*
-------------------------------------------------
2、运行 all_hic 中 ALLHiC_pip.sh ，脚本中需要依赖 samtools 和 bwa(可以在ALLHiC_pip.sh中自行修改依赖软件的路径)
注：写脚本时需要export PATH=/path/ALLHiC/scripts/:/path/ALLHiC/bin:$PATH
-------------------------------------------------
Usage: ALLHiC_pip.sh -r reference -1 R1.fq -2 R2.fq -k group_count [-e enzyme] [-t threads] [-b bin_size]
          -r: reference genome
          -1: Lib_R1.fq.gz
          -2: Lib_R2.fq.gz
          -k: group_count
          -e: enzyme_sites (HindIII: AAGCTT; MboI: GATC), default: HindIII
          -t: threads, default: 10
          -b: bin_size for hic heatmap, can be divided with comma, default: 500k
-------------------------------------------------
脚本报错的话就选择分部执行
一般报错原因是因为sorted.bam文件中有多余HD注释行可以用以下命令继续处理，然后再继续执行后面步骤即可：
samtools view -h sorted.bam | sed -e '/@HD\tVN:1.5\tSO:unsorted\tGO:query/d' | samtools view -b -o deal_sorted.bam
