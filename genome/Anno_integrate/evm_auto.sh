#!/bin/sh

species=S_japo
genome=genome.fa
cpu=48
weight=weights.txt
denovo=denovo.gff
pep=pep.gff
RNA=RNA.gff
repeats=all.repeat.gff
segmentSize=1000000
overlapSize=200000
min_intron_length=20

export PERL5LIB=/01_software/TransDecoder-TransDecoder-v5.5.0/PerlLib:$PERL5LIB

cat ${pep} ${RNA} ${denovo} | grep -v "^#" | cut -f 1 | sed '/^\s*$/d' | awk '!a[$1]++' | seqtk subseq -l 100 ${genome} - > ${genome}.filter.fa

/01_software/EVidenceModeler-v2.1.0/EVidenceModeler \
                   --sample_id ${species} \
                   --genome ${genome}.filter.fa \
                   --weights ${weight} \
                   --gene_predictions ${denovo} \
                   --protein_alignments ${pep} \
                   --transcript_alignments ${RNA} \
                   --segmentSize ${segmentSize} \
                   --overlapSize ${overlapSize} \
                   --CPU ${cpu} \
                   --repeats ${repeats} \
                   --min_intron_length ${min_intron_length}
