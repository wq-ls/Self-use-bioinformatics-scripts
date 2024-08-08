genome=ABCD.fa
pep=all.pep.rmdup.fa
out=spaln.gff
cpu=10
db=$PWD/seqdb/genome
sif=/singularity_all/spaln3.sif

[ -d seqdb ] || mkdir seqdb
cp ${genome} seqdb/genome.gf

cd seqdb
/usr/bin/singularity run --bind $PWD/:$PWD/ ${sif} /spaln_data/bin/spaln -W -KP -g genome.gf
cd ../

/usr/bin/singularity run --bind $PWD/:$PWD/ ${sif} /spaln_data/bin/spaln -Q7 -LS -pw -S3 -O0 -pi -yE 10 -yL 30 -t ${cpu} -D ${db} ${pep} > ${out} 2> Log.spaln

rm -rf $PWD/seqdb
