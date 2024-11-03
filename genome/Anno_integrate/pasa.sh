#!/bin/bash
set +o posix

### need copy and change *config to your work path !!!!!!!!!!!

### export env
PASAPIPELINE=/01_soft/PASApipeline.v2.5.3
export PATH=${PASAPIPELINE}:${PASAPIPELINE}/scripts/:${PASAPIPELINE}/misc_utilities/:$PATH
unset PERL5LIB; export PATH=/softs/perl-5.30.2/bin:$PATH
export PATH=/blast-2.2.26/bin/:$PATH                                                      ### blast
export PATH=/gmap-2021-08-25/bin:$PATH                  ### gmap
export PATH=${PASAPIPELINE}/bin:$PATH                                                               ### minimap2 pblat blat and other dependency softwares
export PATH=/01_software/TransDecoder-TransDecoder-v5.5.0/:$PATH    ### TransDecoder
export PATH=/01_soft/PASApipeline.v2.5.3/bin:$PATH

### change parameter
genome=HCS_chr.fa
gff=HCS.EVM.bgi.filter.gff
gff3=${gff}.gff3
trans=trans.cdhit.rename.fa
trans_clean=${trans}.clean
cpu=73
max_intron_legth=2000000
config1=alignAssembly.config
config2=annotCompare.config
align_software=minimap2         ### gmap blat minimap2 pblat
stringent_alignment_overlap=30  ### overlapping transcripts must have this min % overlap to be clustered.
gene_overlap=50                 ### transcripts overlapping existing gene annotations are clustered.  Intergenic alignments are clustered by default mechanism.

### step1: clean trans
mkdir step1_clean
cd step1_clean
ln -s ../${trans} ./
${PASAPIPELINE}/bin/seqclean $trans -c 15 -v /00_tools/Clean-fasta/UniVec
cd ../
ln -s step1_clean/${trans}* ./

### step2: align
perl change_gff_format.pl ${gff} ${gff3}
${PASAPIPELINE}/bin/samtools faidx ./${trans}
${PASAPIPELINE}/Launch_PASA_pipeline.pl --config $config1 --annot_compare --ALT_SPLICE --create --replace --run --genome ./$genome --transcripts ./$trans_clean --ALIGNERS $align_software -T -u ./$trans --CPU $cpu --MAX_INTRON_LENGTH ${max_intron_legth} --TRANSDECODER --stringent_alignment_overlap ${stringent_alignment_overlap} --annots ${gff3}

## step2: compare
${PASAPIPELINE}/scripts/build_comprehensive_transcriptome.dbi -c $config1 -t $trans_clean --min_per_ID 95 --min_per_aligned 30
## annot_compare_R1
${PASAPIPELINE}/Launch_PASA_pipeline.pl -c $config2 -g ${genome} -t $trans_clean -A -L --annots $gff3 --CPU $cpu
## annot_compare_R2 ### Attention here
recent_update_file=$(ls -t *gene_structures_post_PASA_updates.*.gff3 | head -n 1)
${PASAPIPELINE}/Launch_PASA_pipeline.pl -c $config2 -g ${genome} -t $trans_clean -A -L --annots $recent_update_file --CPU $cpu

## step3: alt_splice_analysis
${PASAPIPELINE}/Launch_PASA_pipeline.pl -c $config2 -g ${genome} -t $trans_clean --CPU $cpu --ALT_SPLICE

## step4: find_orfs_in_pasa_assemblies ### Attention here
DBname_assemblies_fasta=$(ls *assemblies.fasta)
DBname_pasa_assemblies_gff3=$(ls *pasa_assemblies.gff3)
${PASAPIPELINE}/scripts/pasa_asmbls_to_training_set.dbi --pasa_transcripts_fasta $DBname_assemblies_fasta --pasa_transcripts_gff3 $DBname_pasa_assemblies_gff3
