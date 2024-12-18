#!/bin/bash
source activate /01_soft/mamba/envs/DeepTE

input_fasta=$PWD/unknow.fa
species=M     # P or M or F or O. P:Plants, M:Metazoans, F:Fungi, and O: Others.
tmp_dir=DeepTE_TmpDir
output_dir=DeepTE_OutDir
Model_dir=/01_soft/DeepTE/Model/Metazoans_model   # Metazoans_model Fungi_model Others_model UNS_model
script=/01_soft/DeepTE/DeepTE.py
probability_threshold=0.6

mkdir ${tmp_dir}
mkdir ${output_dir}

python3 /01_soft/DeepTE/DeepTE_domain.py -d ${tmp_dir} -o ${output_dir} -i ${input_fasta} -s /01_soft/DeepTE/supfile_dir --hmmscan /01_soft/bin/hmmscan

python3 ${script} -d ${tmp_dir} -o ${output_dir} -i ${input_fasta} -sp ${species} -m_dir ${Model_dir} -prop_thr ${probability_threshold} -modify ${output_dir}/opt_te_domain_pattern.txt
