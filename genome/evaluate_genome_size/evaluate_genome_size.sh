#!/bin/sh
set +o posix

prefix=yu
NGS_fq1=ABCD_1.clean.fq.gz
NGS_fq2=ABCD_2.clean.fq.gz
mer_len=19
cpu=30
ploidy=2
read_len=150

## count k-mers
jellyfish count -m ${mer_len} -s 1000000000 -t ${cpu} -C -o ${prefix}.count.jf <(pigz -p 5 -d -c ${NGS_fq1}) <(pigz -p 5 -d -c ${NGS_fq2})
#jellyfish count -m ${mer_len} -s 1000000000 -t ${cpu} -C -o ${prefix}.count *.fq

## if jellyfish gives you more than one count file, you need merge them firs
# jellyfish merge -v -o ${prefix}.count.jf ${prefix}.count_*

jellyfish stats -o ${prefix}.stats ${prefix}.count.jf
jellyfish histo -t ${cpu} ${prefix}.count.jf > ${prefix}.histo

<<another_soft
[ -d tmp ] || mkdir tmp
/01_soft/KMC/bin/kmc -k19 -t20 -m100 -ci1 -cs10000 @fq.list reads tmp/
/01_soft/KMC/bin/kmc_tools transform reads histogram reads.histo -cx10000
another_soft

## plot, not work, have some problem
Rscript /genomescope2.0/genomescope.R -i ${prefix}.histo -o ${prefix} -k ${mer_len} -n ${prefix}.model_2 --ploidy {ploidy}
Rscript /genomescope/genomescope.R ${prefix}.histo ${mer_len} ${read_len} result2 100000 verbose

<<another_soft2
awk '{print $1"\t"$2}' ${prefix}.histo > ${prefix}.histo.tsv
Genomeye -k ${mer_len} ${prefix}.histo.tsv > Genomeye.result
## check kmernum: cat ${prefix}.stats
## kmernum: 118233500882    expected_depth_for_unique_kmer: 76
gce -g 118233500882 -f ${prefix}.histo.tsv -m 1 -D 1 -c 76 >O.gce.table 2>O.gce.log
tail O.gce.log
another_soft2
