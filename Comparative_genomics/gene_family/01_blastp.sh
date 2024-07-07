gffread ./00_data/C_albu.bgi.gff -g ./00_data/C_albu.fa -x ./00_data/cds.fa 
seqkit translate --trim --clean ./00_data/cds.fa > ./00_data/pep.fa 
makeblastdb -in ./00_data/TLR_protein.fasta -dbtype prot -out blastdb 
blastp -query ./00_data/pep.fa -db blastdb  -evalue 1e-05 -seg yes -outfmt '7 qseqid qstart qend sseqid sstart send qlen slen length pident evalue' -num_threads 5 > ./1_identify_gene_family/01_blastp/blastp.txt 
grep -v '#' ./1_identify_gene_family/01_blastp/blastp.txt |awk '$9/$8 > 0.8 || $9/$7 >0.8' > ./1_identify_gene_family/01_blastp/blastp.txt.filt 
awk '{print $1}' ./1_identify_gene_family/01_blastp/blastp.txt.filt | sort -u > ./1_identify_gene_family/01_blastp/blast.filt.id 
