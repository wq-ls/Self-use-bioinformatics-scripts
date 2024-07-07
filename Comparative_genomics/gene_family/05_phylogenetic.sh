muscle -align ./1_identify_gene_family/04_final_gene_family/final_gene_protein -output ./2_phylogenetic/gene_protein.muscle 
trimal -in ./2_phylogenetic/gene_protein.muscle -out ./2_phylogenetic/gene_protein.muscle.trimal -automated1 
grep '^>' ./2_phylogenetic/gene_protein.muscle | sed 's/>//' > ./2_phylogenetic/gene_protein.muscle.name 
iqtree2 -s ./2_phylogenetic/gene_protein.muscle.trimal -m MFP -nt AUTO -B 1000 > ./2_phylogenetic/iqtree
