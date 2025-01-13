source activate /01_software/miniconda3/envs/mitozEnv

mitoz all  \
--outprefix qingyi \
--thread_number 20 \
--clade Chordata \
--species_name "Choerodon_schoenleinii" \
--workdir AUTOPL2111250159 \
--fq1 ABCD_1.clean.fq.gz \
--fq2 ABCD_2.clean.fq.gz \
--fastq_read_length 150 \
--data_size_for_mt_assembly 2 \
--assembler megahit \
--memory 50 \
--requiring_taxa Chordata
