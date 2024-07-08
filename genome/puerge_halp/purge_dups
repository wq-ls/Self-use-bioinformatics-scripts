利用purge_dups对基因组进行去冗余操作
1、软件安装
----------------------------------------------
git clone https://github.com/dfguan/purge_dups.git
cd purge_dups/src && mak
-----------------------------------------------
2、运行脚本
-----------------------------------------------
#第一步
minimap2 -t 5 -xasm5 -DP assembly.fa pacbio.fa.gz  | gzip -c - > pb_aln.paf.gz
pbcstat pb_aln.paf.gz
calcuts PB.stat > cutoffs 2> calcults.log
#第二步
split_fa assembly.fa > asm.split
minimap2 -t 5 -xasm5 -DP  asm.split asm.split | gzip -c - > assembly.fasta.split.self.paf.gz
#第三步
purge_dups 2 -T cutoffs -c PB.base.cov assembly.fasta.split.self.paf.gz > dups.bed 2> purge_dups.log
#第四步
get_seqs dups.bed  assembly.fa
-----------------------------------------------
