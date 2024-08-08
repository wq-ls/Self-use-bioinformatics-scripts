genome=ABCD.fa
pep=pep.fa
outgff=GTH_predict.gff

gth -intermediate -gff3out -genomic ${genome} -protein ${pep} > ${outgff}
rm ${genome}.dna.*  ${pep}.protein.*  *md5

awk '$3=="gene" || $3=="exon"' GTH_predict.gff | sed 's/exon/CDS/g;s/gene/mRNA/g' | awk -F ";" '{print $1";"}' > GTH_predict.bgi.gff
grep -v "#" GTH_predict.bgi.gff | gffread -C -G -K -Q -Y -M --cset -d dup -H -V -P -N -Z - -g ${genome} -o gth.deal.gff
awk '$3=="mRNA" || $3=="CDS"' gth.deal.gff | awk -F ";" '{print $1";"}' > gth.deal.bgi.gff
Covert_for_evm.pl gth.deal.bgi.gff gth > gth.gff.forevm.gff3
