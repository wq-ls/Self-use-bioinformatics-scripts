export PATH="/01_soft/kmerDedup/:$PATH"

prefix=YZ
genome=curated.fasta
mer_len=19
cpu=70
counter_len=8
NGS_fq1=YZ_clean.R1.fq.gz
NGS_fq2=YZ_clean.R2.fq.gz
ccs_fa=yz.fasta.gz

## step1 count k-mers
jellyfish count -m ${mer_len} -s 100M -t ${cpu} -c ${counter_len} -C -o ${prefix}.count <(pigz -p 5 -d -c ${NGS_fq1}) <(pigz -p 5 -d -c ${NGS_fq2}) <(zcat ${ccs_fa})

## if jellyfish gives you more than one count file, you need merge them firs
# jellyfish merge -v -o ${prefix}.count.jf ${prefix}.count_*

mv ${prefix}.count ${prefix}.count.jf

## step2 stat and histo (you can skip)
jellyfish stats -o ${prefix}.stats ${prefix}.count.jf
jellyfish histo -t ${cpu} ${prefix}.count.jf | perl -lane 'my ($dpt, $cnt) = split(/\s+/, $_); my $nn = $dpt * $cnt;print "$dpt\t$cnt\t$nn"' > ${prefix}.histo

## plot, not work, have some problem
# Rscript /01_software/genomescope/genomescope2.0/genomescope.R -i ${prefix}.histo -o ${prefix} -k ${mer_len} -n ${prefix}.model_2

## step3 dump k-mers
jellyfish dump -c -t -o ${prefix}.dump.all ${prefix}.count.jf
perl /01_soft/kmerDedup/kmerDedup/kmerFilter.pl -d ${prefix}.dump.all -o ${prefix}.filt.fa -l 3 -u 100000
perl /01_soft/kmerDedup/kmerDedup/splitFasta.pl -f ${prefix}.filt.fa -o split -k ${prefix}.kmer

## step4 mapping k-mers
perl  /01_soft/kmerDedup/kmerDedup/fa2fa.pl -f ${genome} -o ${prefix}.format.fa -c F -n F -l 1000

bowtie2-build --threads ${cpu} ${prefix}.format.fa ${prefix}.format
ls split/ > split.id
[ -d shell ] || mkdir shell

for i in $(cat split.id); do sed "s/ABCD/${i}/g" bowtie2_demo.sh > shell/bowtie2_${i}.sh; done
