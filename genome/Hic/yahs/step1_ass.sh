#!/bin/bash
set +o posix

genome=YZ_CRAQ.fa
hic_fq1=YZ_clean.R1.fq.gz
hic_fq2=YZ_clean.R2.fq.gz
cpu=48

### chromap map
samtools faidx ${genome}
chromap -i -r ${genome} -o genome.index
chromap --preset hic -r ${genome} -x genome.index --remove-pcr-duplicates -1 ${hic_fq1} -2 ${hic_fq2} --SAM -o aligned.sam -t ${cpu}
samtools view -bh aligned.sam | samtools sort -@ ${cpu} -n > aligned.bam
rm aligned.sam

### yahs
/00_software/yahs/yahs ${genome} aligned.bam

### juicer
/00_software/yahs/juicer pre -a -o out_Juicer yahs.out.bin yahs.out_scaffolds_final.agp ${genome}.fai > Log.txt 2>&1

juicer=/00_software/juicer_tools_1.19.02.jar
/01_soft/mambaforge/bin/java -Xmx36G -jar $juicer pre out_Juicer.txt out_Juicer.hic <(cat Log.txt | grep "PRE_C_SIZE" | awk '{print $2" "$3}')
