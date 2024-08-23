### https://github.com/reubwn/collinearity/tree/v1.0
export PATH="/01_soft/MCScanX/:$PATH"
export PATH="/01_soft/collinearity:$PATH"

pep=2.gff.pep
cds=2.gff.cds
gff=2.gff
cpu=30

##
diamond makedb --in ${pep} -d ${pep}
diamond blastp -e 1e-2 -p 8 -q ${pep} -d ${pep} -a ${pep}.vs.self
diamond view -a ${pep}.vs.self.daa -o Xyz.blast
awk '$3=="mRNA"' ${gff} | awk '{print $1"\t"$9"\t"$4"\t"$5}' | sed 's/ID=//g;s/;//g' > Xyz.gff

##
[ -d result ] || mkdir result
cp Xyz* result
MCScanX result/Xyz
duplicate_gene_classifier result/Xyz

##
add_kaks_to_MCScanX.pl -i result/Xyz.collinearity -p ${pep} -c ${cds} -t ${cpu}
calculate_collinearity_metric.pl -i result/Xyz.collinearity -g Xyz.gff -k result/Xyz.collinearity.kaks
calculate_collinearity_breakpoints.pl -i result/Xyz.collinearity -g Xyz.gff -s result/Xyz.collinearity.score -k result/Xyz.collinearity.kaks -b
calculate_collinearity_palindromes.pl -i result/Xyz.collinearity -g Xyz.gff -k result/Xyz.collinearity.kaks
