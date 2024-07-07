#! python
# -*- coding: utf-8 -*-

import argparse
import os
parser = argparse.ArgumentParser (description= "The python for creating shell ", usage= '\n'+'python shell.py -g gene_protein_fasta -gff3 genome_gff3 -fa genome_fa -d hmm_file  -r rna_data_list' )

Required_options=parser.add_argument_group("Required arguments")
Required_options.add_argument('--gene_protein_fasta', '-g', help = 'this file is used to makeblastdb', nargs=1, type=str, required=True)
Required_options.add_argument('--genome_gff3', '-gff3', help = 'this file is your target species gene genome gff3', nargs=1, type=str, required=True)
Required_options.add_argument('--genome_fa', '-fa', help = 'this file is your need target species genome sequencing file ', nargs =1, type = str,  required = True)
Required_options.add_argument('--hmm_file', '-d', help = 'this file is target gene domain hmm file', type = str, nargs='+', required = True)
# Required_options.add_argument('--rna_data_list', '-r', help = 'this file is three columns,about name rna_seq_data1 rna_seq_data2', nargs =1, type = str,required = True)

Optional_options = parser.add_argument_group("Optional arguments")
Optional_options.add_argument('--rna_data_list', '-r', help = 'this file is three columns about name rna_seq_data1 rna_seq_data2',type = str, default = "None")
Optional_options.add_argument('--evalue','-e',help='this is all evalue ',type= float, default= 1e-5)
Optional_options.add_argument('--num_threads','-n',help='this is all num_threads ',type= int, default= 5)
Optional_options.add_argument('--identity','-i',help='this is miniprot filter identity ',type= float, default= 0.8)

args = parser.parse_args()
rna_data_list = args.rna_data_list
gene_protein_fasta = args.gene_protein_fasta[0]
genome_gff3 = args.genome_gff3[0]
genome_fa = args.genome_fa[0]
hmm_file = args.hmm_file    # 储存的是一个列表
rna_data_list = args.rna_data_list[0]

evalue = args.evalue
num_threads = args.num_threads
identity = args.identity

def shell (gene_protein_fasta, genome_gff3, genome_fa, hmm_file, rna_data_list, evalue, num_threads, identity):
    with open ('01_blastp.sh', 'w') as f1:
        os.system("mkdir -p ./1_identify_gene_family/01_blastp/ \n")
        f1.write ( 
                   ### step0: gffread get cds.fa protein.fa
                    f"gffread ./00_data/{genome_gff3} -g ./00_data/{genome_fa} -x ./00_data/cds.fa \n"
                  + "seqkit translate --trim --clean ./00_data/cds.fa > ./00_data/pep.fa \n"
                   ### step1: makeblastdb
                  + f"makeblastdb -in ./00_data/{gene_protein_fasta} -dbtype prot -out blastdb \n"
                   ### step2: blastp
                  + f"blastp -query ./00_data/pep.fa -db blastdb  -evalue {evalue} -seg yes -outfmt '7 qseqid qstart qend sseqid sstart send qlen slen length pident evalue' -num_threads {num_threads} > ./1_identify_gene_family/01_blastp/blastp.txt \n"
                   ### step3: filter and get blast.filt.id
                  + "grep -v '#' ./1_identify_gene_family/01_blastp/blastp.txt |awk '$9/$8 > 0.8 || $9/$7 >0.8' > ./1_identify_gene_family/01_blastp/blastp.txt.filt \n"
                  + "awk '{print $1}' ./1_identify_gene_family/01_blastp/blastp.txt.filt | sort -u > ./1_identify_gene_family/01_blastp/blast.filt.id \n" )
    with open('02_hmm.sh' , 'w') as f2:
        os.system("mkdir -p ./1_identify_gene_family/02_hmm/  ./1_identify_gene_family/result \n")
        if len(hmm_file) == 1:
            f2.write ( 
                       ### step1: hmmsearch
                       f"hmmsearch  --domtblout ./1_identify_gene_family/02_hmm/{hmm}.out ./00_data/{hmm} ./00_data/pep.fa \n"
                       ### step2: filter and get hmm.id
                      + f"grep -v '#' ./1_identify_gene_family/02_hmm/{hmm}.out | awk '($7 + 0) < {evalue}'|cut -f1 -d  ' ' |sort -u > ./1_identify_gene_family/02_hmm/hmm.id \n" 
                       ### step3: get gene family (comm blastp hmm)
                      + "comm -12 ./1_identify_gene_family/02_hmm/hmm.id ./1_identify_gene_family/01_blastp/blast.filt.id > ./1_identify_gene_family/result/01_target_gene.id \n"
                       ### step4: get target_gene_pep
                      + "seqkit grep -f ./1_identify_gene_family/result/01_target_gene.id ./00_data/pep.fa > ./1_identify_gene_family/result/02_target_gene.pep \n" )
        else:
            for hmm in hmm_file:
                f2.write ( ### step1: hmmsearch
                           f"hmmsearch  --domtblout ./1_identify_gene_family/02_hmm/{hmm}.out ./00_data/{hmm} ./00_data/pep.fa \n"
                           ### step2: filter and get hmm.id
                           + f"grep -v '#' ./1_identify_gene_family/02_hmm/{hmm}.out | awk '($7 + 0) < {evalue}'|cut -f1 -d  ' ' |sort -u > ./1_identify_gene_family/02_hmm/{hmm}_gene.id \n" )
            num = len (hmm_file)
            f2.write( ### step3: get gene family (comm blastp hmm)
                      "find ./1_identify_gene_family/02_hmm -name '*_gene.id' -exec cat {} \; " + f"|sort |uniq -c |awk '$1 == {num}" + " {print $2}'" +" > ./1_identify_gene_family/02_hmm/hmm.id \n"
                      +  "comm -12 ./1_identify_gene_family/02_hmm/hmm.id ./1_identify_gene_family/01_blastp/blast.filt.id > ./1_identify_gene_family/result/01_target_gene.id \n"
                      ### step4: get target_gene_pep
                      + "seqkit grep -f ./1_identify_gene_family/result/01_target_gene.id ./00_data/pep.fa > ./1_identify_gene_family/result/02_target_gene.pep \n" )

    with open ('03_miniprot.sh', 'w') as f3:
        os.system("mkdir -p ./1_identify_gene_family/03_miniprot  \n")
        f3.write(
                  ### step0: filter gene_protein_fasta; make new_gene_protein_fasta
                   f"blastp -query ./00_data/{gene_protein_fasta} -subject ./1_identify_gene_family/result/02_target_gene.pep -evalue {evalue}" + ''' -seg yes -outfmt "6 qseqid"| sort -u > ./1_identify_gene_family/03_miniprot/new_gene_protein_id \n'''
                  + f"seqkit grep -f ./1_identify_gene_family/03_miniprot/new_gene_protein_id ./00_data/{gene_protein_fasta} > ./1_identify_gene_family/03_miniprot/new_gene_protein_fasta \n"
                  + "cat ./1_identify_gene_family/result/02_target_gene.pep >> ./1_identify_gene_family/03_miniprot/new_gene_protein_fasta \n"
                  ### step1: miniprot; filter
                  + f"miniprot --gff -I ./00_data/{genome_fa} ./1_identify_gene_family/03_miniprot/new_gene_protein_fasta > ./1_identify_gene_family/03_miniprot/miniprot.gff \n"
                  + '''awk '{if($0 ~ /^##/ && $11 != "" && $12 != "" &&''' + f" ($11 + 0)/($12 + 0) > {identity})" + ''' {found=1; next} else {if ($0 ~ /^##/) {found = 0}}} /mRNA/ {if (found == 1) print} /CDS/ {if (found == 1) print}' ./1_identify_gene_family/03_miniprot/miniprot.gff > ./1_identify_gene_family/03_miniprot/miniprot.filt.gff \n'''
                  ### step2: gffread; filter; predict cds
                  + "gffread -C -G -K -Q -Y -M -d dup ./1_identify_gene_family/03_miniprot/miniprot.filt.gff > ./1_identify_gene_family/03_miniprot/miniprot.filt.gff2" + "\n"
                  + f"gffread ./1_identify_gene_family/03_miniprot/miniprot.filt.gff2 -g ./00_data/{genome_fa} -x ./1_identify_gene_family/03_miniprot/pre.cds" )  # 个性化验证

#  经个人验证后得到一个final_gene_id文件 存放于./00_data/final_gene_id
    with open('04_final_gene_family.sh', 'w') as f4:
        os.system("mkdir -p ./1_identify_gene_family/04_final_gene_family \n")
        f4.write(
                  ### step1: get final_gene_id
                  "cp ./00_data/final_gene_id ./1_identify_gene_family/04_final_gene_family/final_gene_id \n"
                  ### step2: get final_gene_protein
                 + "seqkit grep -f ./1_identify_gene_family/04_final_gene_family/final_gene_id ./00_data/pep.fa > ./1_identify_gene_family/04_final_gene_family/final_gene_protein \n"
                  ### step3: get final_gene_cds
                 + f"seqkit grep -f ./1_identify_gene_family/04_final_gene_family/final_gene_id ./00_data/cds.fa > ./1_identify_gene_family/04_final_gene_family/final_gene_cds \n"
                  ### step4: get final_gene_cds_length
                 + "seqkit fx2tab --length --name ./1_identify_gene_family/04_final_gene_family/final_gene_cds | awk '{print $1, $2}'> ./1_identify_gene_family/04_final_gene_family/final_gene_cds_length \n"
                  ### step5: get final_gene_cds_number
                 + f"grep 'CDS' ./00_data/{genome_gff3}" + "| cut -f9 | cut -d ';' -f1 | cut -d '=' -f2 | sort | uniq -c|awk '{print $2, $1}' > ./1_identify_gene_family/04_final_gene_family/gene_cds_number \n"
                 + "grep -f  ./1_identify_gene_family/04_final_gene_family/final_gene_id ./1_identify_gene_family/04_final_gene_family/gene_cds_number |sort  >./1_identify_gene_family/04_final_gene_family/final_gene_cds_number \n"
                  ### step6: get final_gene_domain
                 + "pfam_scan.pl -fasta ./1_identify_gene_family/04_final_gene_family/final_gene_protein -dir ./Pfam/ > ./1_identify_gene_family/04_final_gene_family/final_gene_domain ")

    with open('05_phylogenetic.sh', 'w') as f5:
        os.system("mkdir -p ./2_phylogenetic \n")
        f5.write( 
                  ### step1: muscle alignment
                  "muscle -align ./1_identify_gene_family/04_final_gene_family/final_gene_protein -output ./2_phylogenetic/gene_protein.muscle \n"
                  ### step2: trimal filter ; get name
                 + "trimal -in ./2_phylogenetic/gene_protein.muscle -out ./2_phylogenetic/gene_protein.muscle.trimal -automated1 \n"
                 + "grep '^>' ./2_phylogenetic/gene_protein.muscle | sed 's/>//' > ./2_phylogenetic/gene_protein.muscle.name \n"
                  ### step3: iqtree2 (get .treefile)
                 + "iqtree2 -s ./2_phylogenetic/gene_protein.muscle.trimal -m MFP -nt AUTO -B 1000 > ./2_phylogenetic/iqtree")
    if rna_data_list == "None":
        return
    else:
        with open('06_rna_seq.sh', 'w') as f6:
            os.system("mkdir -p ./3_rna_seq/01_fastp ./3_rna_seq/02_salmon ./3_rna_seq/03_gene_family.quant  ./3_rna_seq/04_visualization")

            f6.write( ### step0: shuffle打乱
                      "seqkit shuffle ./00_data/cds.fa -o ./00_data/cds.fa.shuffle \n"
                      ### step1: for循环  处理每组rna-seq数据
                     + '''OLDIFS="$IFS" \n'''
                     + "IFS=$\'\\n\' " + "\n"
                     + '''for line in $(cat ./00_data/rna_data_list); do \n'''
                     + '''    IFS="$OLDIFS" \n''' 
                     + '''    read -r name rna_seq_data1 rna_seq_data2 <<< "$line" \n''' 
                      ### step2: fastp filter
                     + '''    fastp -i ./00_data/"$rna_seq_data1" -o ./3_rna_seq/01_fastp/"$rna_seq_data1" -I ./00_data/"$rna_seq_data2" -O ./3_rna_seq/01_fastp/"$rna_seq_data2" \n'''
                      ### step3: salmon quant; make index; quant
                     + '''    salmon index -t ./00_data/cds.fa.shuffle -i ./3_rna_seq/02_salmon/cds.fa.index -p 20 -k 31 \n'''
                     + '''    salmon quant -i ./3_rna_seq/02_salmon/cds.fa.index --validateMappings -l A -p 8 -1 ./3_rna_seq/01_fastp/"$rna_seq_data1" -2 ./3_rna_seq/01_fastp/"$rna_seq_data2" -o ./3_rna_seq/02_salmon/"$rna_seq_data1".quant \n'''
                      ### step4: get gene_family quant
                     + '''    grep -f ./1_identify_gene_family/04_final_gene_family/final_gene_id ./3_rna_seq/02_salmon/"$rna_seq_data1".quant/quant.sf |sort > ./3_rna_seq/03_gene_family.quant/"$rna_seq_data1".quant \n'''
                      ### step5: get TPM
                     + '''    echo "$name" > ./3_rna_seq/04_visualization/"$name".sf.TPM ; awk '{print $4}' ./3_rna_seq/03_gene_family.quant/"$rna_seq_data1".quant >> ./3_rna_seq/04_visualization/"$name".sf.TPM \n'''
                     + '''    ''' + "IFS=$\'\\n\' " + "\n"
                     + '''done \n'''
                     + '''IFS="$OLDIFS" \n''' 
                      ### step6: get gene_name; all TPM; make  matrix
                     + '''echo 'gene name' > ./3_rna_seq/04_visualization/gene_name ; awk '{print $1}' ./1_identify_gene_family/04_final_gene_family/final_gene_id >> ./3_rna_seq/04_visualization/gene_name \n'''
                     + '''find ./3_rna_seq/04_visualization/ -name '*.sf.TPM' |paste -sd '\t' > ./3_rna_seq/04_visualization/TPM_file_path \n'''
                     + '''paste ./3_rna_seq/04_visualization/gene_name $(cat ./3_rna_seq/04_visualization/TPM_file_path) > ./3_rna_seq/04_visualization//final_matrix''')

if __name__ == "__main__":
    shell(gene_protein_fasta, genome_gff3, genome_fa, hmm_file, rna_data_list, evalue, num_threads, identity)





