export PATH="/01_soft/kmerDedup/:$PATH"

prefix=YZ
mer_len=19
work_dir=$PWD
bam_dir=${work_dir}/mapping
cpu=30
out_dir=kmerdedup_refilter
mpr=0.3
whitelist=white.list 		## whitelist to keep
blacklist=black.list		## blacklist to remove

## -mpr  <float>  max duplication percentage  [0.3]
## -mcv  <int>    min k-mer coverage(%)       [30]
## -mode <1/2>    1:ratio only; 2:ratio * cov [2]

perl /01_soft/kmerDedup/kmerDedup/kmerDedup.pl -k ${prefix} -mpr ${mpr} -mcv 30 -kmer ${mer_len} -o ${out_dir} -f ${prefix}.format.fa -dum ${prefix}.dump.hash ./ -cov ${prefix}.cov.stat -s samtools -t ${cpu} -mode 2 -wtl ${whitelist} -bll ${blacklist}
