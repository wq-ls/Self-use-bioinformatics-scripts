genome=genome.fa
threads=48

## miscRNA from egapx

## barrnap for rRNA
/01_software/barrnap-0.9/bin/barrnap --kingdom euk --threads ${threads} ${genome} > rRNA_barrnap.gff

## aragorn for tRNA
#/soft/aragorn -mt -a -t -m -i ${genome} -o tRNA.tsv

## tRNAscan_SE for tRNA
export PATH=$PATH:/noncoding_soft/tRNAscan-SE-2.0/bin
export PERL5LIB=/noncoding_soft/tRNAscan-SE-2.0/lib:$PERL5LIB
export PATH=$PATH:/noncoding_soft/tRNAscan-SE-2.0

tRNAscan_SE_config=/noncoding_soft/tRNAscan-SE-2.0/tRNAscan-SE.conf
## for vert vertebrate
tRNAscan-SE -q -o tRNA.tsv -m statistics.summary -f tRNA_secondary.structures -M vert -c ${tRNAscan_SE_config} ${genome}
