## https://flair.readthedocs.io/en/latest/other_ways.html

genome=fcs.fa
gtf=fcs.gtf
fq=SRR17056084.fastq
cpu=50


### module numbers: align=1, correct=2, collapse=3, collapse-range=3.5, quantify=4, diffExp=5, diffSplice=6
flair align -r ${fq} -g ${genome} -t ${cpu} --junction_bed out_junction.bed

flair correct -q flair.aligned.bed -g ${genome} --threads ${cpu} -f ${gtf}

[ -d temp_flair ] || mkdir temp_flair
flair collapse -r ${fq} -q flair_all_corrected.bed -g ${genome} -o flair.output --temp_dir temp_flair -t ${cpu} --keep_intermediate -f ${gtf} --no_gtf_end_adjustment --max_ends 5 --check_splice --generate_map
