export PATH="/01_soft/kmerDedup/:$PATH"

prefix=YZ
mer_len=19
work_dir=$PWD
bam_dir=${work_dir}/mapping
cpu=30

grep "" shell/*sh.e* | sed 's/:/\t/g;s/\//\t/g;s/.fa.sh./\t/g' | cut -f 2,4 > alignment_rate.txt
ls ${bam_dir}/*.bam > bam.list
samtools merge -@ ${cpu} -n -f -b bam.list ${prefix}.keymer_map.bam
BamDeal statistics Coverage -i ${prefix}.keymer_map.bam -r ${prefix}.format.fa -q 0 -o ${prefix}.cov

## -mpr  <float>  max duplication percentage  [0.3]
## -mcv  <int>    min k-mer coverage(%)       [30]
## -mode <1/2>    1:ratio only; 2:ratio * cov [2]

perl /01_soft/kmerDedup/kmerDedup/kmerDedup.pl -k ${prefix} -mpr 0.3 -mcv 30 -kmer ${mer_len} -o kmerdedup_mpr3 -f ${prefix}.format.fa -bam ${prefix}.keymer_map.bam -cov ${prefix}.cov.stat -s samtools -t ${cpu} -mode 2
cp kmerdedup_mpr3/${prefix}.dump.hash ./

## plot
sed '1d' kmerdedup_mpr3/${prefix}.all.xls | cut -f 1,2,7,8 | sort -k 3nr,3 | awk '{print NR","$3","$1","$2","$4}' | csvtk add-header -n num,cov,name,length,state > ${prefix}.all.deal.csv
csvtk plot line --height 6 --width 20 -x 1 -y 2 ${prefix}.all.deal.csv > ${prefix}.all.deal.csv.png
csvtk pretty ${prefix}.all.deal.csv > ${prefix}.all.deal.pretty.csv

### remove tmp
#rm -rf ${prefix}.count.jf ${prefix}.dump.all ${prefix}.filt.fa split mapping shell *bt2 ${prefix}.keymer_map.bam
