hmmsearch  --domtblout ./1_identify_gene_family/02_hmm/TIR.hmm.out ./00_data/TIR.hmm ./00_data/pep.fa 
grep -v '#' ./1_identify_gene_family/02_hmm/TIR.hmm.out | awk '($7 + 0) < 1e-05'|cut -f1 -d  ' ' |sort -u > ./1_identify_gene_family/02_hmm/TIR.hmm_gene.id 
hmmsearch  --domtblout ./1_identify_gene_family/02_hmm/LRR.hmm.out ./00_data/LRR.hmm ./00_data/pep.fa 
grep -v '#' ./1_identify_gene_family/02_hmm/LRR.hmm.out | awk '($7 + 0) < 1e-05'|cut -f1 -d  ' ' |sort -u > ./1_identify_gene_family/02_hmm/LRR.hmm_gene.id 
find ./1_identify_gene_family/02_hmm -name '*_gene.id' -exec cat {} \; |sort |uniq -c |awk '$1 == 2 {print $2}' > ./1_identify_gene_family/02_hmm/hmm.id 
comm -12 ./1_identify_gene_family/02_hmm/hmm.id ./1_identify_gene_family/01_blastp/blast.filt.id > ./1_identify_gene_family/result/01_target_gene.id 
seqkit grep -f ./1_identify_gene_family/result/01_target_gene.id ./00_data/pep.fa > ./1_identify_gene_family/result/02_target_gene.pep 
