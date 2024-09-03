### https://github.com/zengxiaofei/HapHiC

micromamba activate haphic
export PATH="/01_soft/HapHiC/:$PATH"
export PATH="/01_soft/HapHiC/utils/:$PATH"

genome=$PWD/chr.fa
hic1=$PWD/hic_getreads.R1.fq.gz
hic2=$PWD/hic_getreads.R2.fq.gz
cpu=60

bwa index ${genome}
bwa mem -5SP -t ${cpu} ${genome} ${hic1} ${hic2} | samblaster | samtools view - -@ ${cpu} -S -h -b -F 3340 -o HiC.bam
filter_bam HiC.bam 1 --nm 3 --threads ${cpu} | samtools view - -b -@ ${cpu} -o HiC.filtered.bam

mock_agp_file.py ${genome} > ${genome}.agp
