
Species=HCS
genome=HCS_chr.softmask.fa
pep=train.pep
thread=70

/usr/bin/singularity exec -B $PWD/:$PWD/ galba.sif galba.pl --species=${Species} --genome=${genome} --prot_seq=${pep} --AUGUSTUS_CONFIG_PATH=/0_soft/augustus/Augustus/config --threads ${thread}

gtf2gff.pl <GALBA/galba.gtf --gff3 --out=GALBA/galba.gff3
grep -v -e intron -e exon  GALBA/galba.gff3 | sed 's/galba.gff3://g' | gffread  | grep -v "#" | awk -F ";" '{print $1";"}' | sed 's/AUGUSTUS/GALBA/g' > GALBA/galba.deal.gff3
change.name.pl GALBA/galba.deal.gff3 GALBA_ > GALBA/galba.bgi.gff
gffread GALBA/galba.bgi.gff -g ${genome} -x GALBA/galba.bgi.gff.cds -y GALBA/galba.bgi.gff.pep
