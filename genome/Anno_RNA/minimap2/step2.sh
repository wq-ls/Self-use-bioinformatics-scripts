trans=transcripts.fasta
cpu=2
### /06_database/SwissProt/uniprot_sprot
blastp_db=/01_genome/Jipidongwu_db/jipidongwu
pfam_db=/06_database/Pfam/Pfam-A.hmm
blastp_soft=/01_soft/ncbi-blast-2.15.0+/bin/blastp
diamond_soft=/00_tools/diamond
evalue=1e-3
hmmscan_soft=/01_soft/mambaforge/bin/hmmscan

ln -s ${trans}.transdecoder_dir/longest_orfs.pep .
fastaDeal.pl --cutf 200 longest_orfs.pep

mkdir blast.qsub  pfam.qsub
for i in `seq 1 200`
do
#echo "${blastp_soft} -query ../longest_orfs.pep.cut/longest_orfs.pep.${i} -db ${blastp_db} -max_target_seqs 1 -outfmt 6 -evalue ${evalue} -num_threads ${cpu} > blastp.${i}.outfmt6 ; echo done " > blast.qsub/blast.${i}.sh
echo "diamond blastp --evalue ${evalue} --outfmt 6 -d ${blastp_db} -q ../longest_orfs.pep.cut/longest_orfs.pep.${i} -o blastp.${i}.outfmt6 --threads $cpu --max-target-seqs 5 --more-sensitive -b 0.5 " > blast.qsub/blast.${i}.sh
echo "${hmmscan_soft} --cpu ${cpu} --domtblout pfam.${i}.domtblout ${pfam_db} ../longest_orfs.pep.cut/longest_orfs.pep.${i} ; echo done " > pfam.qsub/pfam.${i}.sh
done
