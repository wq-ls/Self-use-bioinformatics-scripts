#!/bin/bash
set +o posix
set -eo pipefail
#export BLAST_USAGE_REPORT=false

if [[ $# == '0' ]]; then
    echo "usage: bidui target query fasta_type soft output_name cpu"
    echo "note: fasta_type: nucl; prot"
    echo "note: soft: blastn; blastp"
    echo "example: bidui db.fa test.fa nucl blastn result.txt 10"
    echo "         bidui db.fa test.fa prot blastp result.txt 10"
    exit 1
fi

target=$1
query=$2
fasta_type=$3
soft=$4
output_name=$5
cpu=$6
soft_path=ncbi-blast-2.13.0+/bin

${soft_path}/makeblastdb -in ${target} -dbtype ${fasta_type} -out ./blastdb/${target} -parse_seqids
${soft_path}/${soft} -task ${soft} -db ./blastdb/${target} -query ${query} -out ${output_name} -outfmt '7 qseqid qstart qend sseqid sstart send qlen slen length pident evalue' -num_threads ${cpu}
