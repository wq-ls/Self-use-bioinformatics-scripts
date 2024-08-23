edited_assembly=out_YZ.review.assembly
out_final_assembly_prefix=out_YZ.review.final
liftover_agp=out_YZ.liftover.agp
contig_genome=YZ.asm.hic.p_ctg.fasta

/dellfsqd2/ST_OCEAN/USER/lichen2/00_software/yahs/juicer post -o ${out_final_assembly_prefix} ${edited_assembly} ${liftover_agp} ${contig_genome}
