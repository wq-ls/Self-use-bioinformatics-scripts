
reference=$PWD/reference
species=HCS
transcript=all.rename.cdhit99.trans.fa
cpu=10
min_identity=0.7
max_intronlength_middle=20000
total_intron_length=100000
output_format=gff3_gene
output_name=GMAP

### In order to handle program received signal SIGSEGV erro alone, split transcript fasta

fastaDeal.pl --cuts 100 ${transcript}
ls ${transcript}.cut > id
for i in $(cat id)
do
    echo "/gmap-2021-08-25/bin/gmap -D $reference -d ${species}_reference --min-identity ${min_identity} --canonical-mode 2 --max-intronlength-middle ${max_intronlength_middle} --totallength ${total_intron_length} -t $cpu --input-buffer-size=20 --output-buffer-size=20 --allow-close-indels=2 --tolerant --truncate --split-large-introns --suboptimal-score=0.9 -f $output_format $PWD/${transcript}.cut/${i} > $PWD/${transcript}.cut/${output_name}.${i}.gff 2> $PWD/${transcript}.cut/${output_name}.${i}.log" >> all.run.sh
done

### Do not deliver tasks in parallel
qsub -cwd -l vf=10G,p=10 -binding linear:10 -q XXX -P XXX all.run.sh
