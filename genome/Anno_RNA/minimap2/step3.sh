
cat pfam.qsub/pfam.1.domtblout > pfam.domtblout
for i in `seq 2 200`
do
    less pfam.qsub/pfam.${i}.domtblout |grep -v '^#' >> pfam.domtblout
done

cat blast.qsub/*outfmt6 | awk '$3>60' > blastp.outfmt6
