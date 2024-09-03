#!/bin/bash
## https://github.com/huangnengCSU/compleasm

### Important parameters
input_genome=genome.fa
cpu=48
database_prefix=actinopterygii
min_bestScore=0.95          # output if score at least FLOAT*bestScore [0.95]
database_path=
compleasm=~/01_software/compleasm/compleasm.py

### Threshold parameters    # Tips: A threshold that is too low may result in falsely high results

min_diff=0.2                # The thresholds for the best matching and second best matching. default=0.2
min_identity=0.6            # The identity threshold for valid mapping results. default=0.4
min_length_percent=0.6      # The fraction of protein for valid mapping results. default=0.6
min_complete=0.9            # The length threshold for complete gene. default=0.9

### other parameters
output_dir=00_assessment
mode=busco                 #lite or busco
#lite:  Without using hmmsearch to filtering protein alignment.
#busco: Using hmmsearch on all candidate predicted proteins to purify the miniprot alignment to improve accuracy.

### CMD
/usr/bin/singularity exec compleasm.sif python ${compleasm} run -a ${input_genome} -o ${output_dir} -l ${database_prefix} -t ${cpu} -m ${mode} --outs ${min_bestScore} -L ${database_path} --min_diff ${min_diff} --min_identity ${min_identity} --min_length_percent ${min_length_percent} --min_complete ${min_complete}

rm -rf ${output_dir}/*_odb10/*.done ${output_dir}/*_odb10/hmmer_output
pigz --best ${output_dir}/*_odb10/miniprot_output.gff
pigz --best ${output_dir}/*_odb10/translated_protein.fasta
pigz --best ${output_dir}/*_odb10/gene_marker.fasta

### for more help
## /usr/bin/singularity exec compleasm.sif python ${compleasm} -h
