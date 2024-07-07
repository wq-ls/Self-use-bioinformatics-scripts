cp ./00_data/final_gene_id ./1_identify_gene_family/04_final_gene_family/final_gene_id 
seqkit grep -f ./1_identify_gene_family/04_final_gene_family/final_gene_id ./00_data/pep.fa > ./1_identify_gene_family/04_final_gene_family/final_gene_protein 
seqkit grep -f ./1_identify_gene_family/04_final_gene_family/final_gene_id ./00_data/cds.fa > ./1_identify_gene_family/04_final_gene_family/final_gene_cds 
seqkit fx2tab --length --name ./1_identify_gene_family/04_final_gene_family/final_gene_cds | awk '{print $1, $2}'> ./1_identify_gene_family/04_final_gene_family/final_gene_cds_length 
grep 'CDS' ./00_data/C_albu.bgi.gff| cut -f9 | cut -d ';' -f1 | cut -d '=' -f2 | sort | uniq -c|awk '{print $2, $1}' > ./1_identify_gene_family/04_final_gene_family/gene_cds_number 
grep -f  ./1_identify_gene_family/04_final_gene_family/final_gene_id ./1_identify_gene_family/04_final_gene_family/gene_cds_number |sort  >./1_identify_gene_family/04_final_gene_family/final_gene_cds_number 
pfam_scan.pl -fasta ./1_identify_gene_family/04_final_gene_family/final_gene_protein -dir ./Pfam/ > ./1_identify_gene_family/04_final_gene_family/final_gene_domain 
