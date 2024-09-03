edited_assembly=out_JBAT.review.assembly
out_final_assembly_prefix=Juicer
liftover_agp=out_JBAT.liftover.agp
contig_genome=YZ.keep.fa

/dellfsqd2/ST_OCEAN/USER/lichen2/00_software/yahs/juicer post -o ${out_final_assembly_prefix} ${edited_assembly} ${liftover_agp} ${contig_genome}
