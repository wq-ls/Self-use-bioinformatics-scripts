seqkit shuffle ./00_data/cds.fa -o ./00_data/cds.fa.shuffle 
OLDIFS="$IFS" 
IFS=$'\n' 
for line in $(cat ./00_data/rna_data_list); do 
    IFS="$OLDIFS" 
    read -r name rna_seq_data1 rna_seq_data2 <<< "$line" 
    fastp -i ./00_data/"$rna_seq_data1" -o ./3_rna_seq/01_fastp/"$rna_seq_data1" -I ./00_data/"$rna_seq_data2" -O ./3_rna_seq/01_fastp/"$rna_seq_data2" 
    salmon index -t ./00_data/cds.fa.shuffle -i ./3_rna_seq/02_salmon/cds.fa.index -p 20 -k 31 
    salmon quant -i ./3_rna_seq/02_salmon/cds.fa.index --validateMappings -l A -p 8 -1 ./3_rna_seq/01_fastp/"$rna_seq_data1" -2 ./3_rna_seq/01_fastp/"$rna_seq_data2" -o ./3_rna_seq/02_salmon/"$rna_seq_data1".quant 
    grep -f ./1_identify_gene_family/04_final_gene_family/final_gene_id ./3_rna_seq/02_salmon/"$rna_seq_data1".quant/quant.sf |sort > ./3_rna_seq/03_gene_family.quant/"$rna_seq_data1".quant 
    echo "$name" > ./3_rna_seq/04_visualization/"$name".sf.TPM ; awk '{print $4}' ./3_rna_seq/03_gene_family.quant/"$rna_seq_data1".quant >> ./3_rna_seq/04_visualization/"$name".sf.TPM 
    IFS=$'\n' 
done 
IFS="$OLDIFS" 
echo 'gene name' > ./3_rna_seq/04_visualization/gene_name ; awk '{print $1}' ./1_identify_gene_family/04_final_gene_family/final_gene_id >> ./3_rna_seq/04_visualization/gene_name 
find ./3_rna_seq/04_visualization/ -name '*.sf.TPM' |paste -sd '	' > ./3_rna_seq/04_visualization/TPM_file_path 
paste ./3_rna_seq/04_visualization/gene_name $(cat ./3_rna_seq/04_visualization/TPM_file_path) > ./3_rna_seq/04_visualization//final_matrix