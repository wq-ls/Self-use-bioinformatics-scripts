## https://github.com/weberlab-hhu/Helixer

species=hcs
genome=$PWD/HCS_chr.fa
out_gff=$PWD/helixer.predict.gff
lineage=invertebrate	# {vertebrate,land_plant,fungi,invertebrate}
model=/Helixer_models/models/invertebrate/invertebrate_v0.3_m_0100.h5
# fungi: /Helixer_models/models/fungi/fungi_v0.3_a_0100.h5
# invertebrate: /Helixer_models/models/invertebrate/invertebrate_v0.3_m_0100.h5
# land_plant: /Helixer_models/models/land_plant/land_plant_v0.3_a_0080.h5
# vertebrate: /Helixer_models/models/vertebrate/vertebrate_v0.3_m_0080.h5
batch_size=8		# large batch_size means needing more GPU memory. {5,6} may ok on one GPU card.
TMP=$PWD/TMP

### get help
# /usr/bin/singularity exec --bind $PWD/:$PWD/ helixer.sif Helixer.py -h

### download best model to !!!!!! your homedir .local/share/Helixer !!!!!
#/usr/bin/singularity exec --bind $PWD/:$PWD/ helixer.sif fetch_helixer_models.py

### main script. "--nv" mean support GPU, cpu is also ok.
[ -d TMP ] || mkdir TMP
/usr/bin/singularity run --bind $PWD/:$PWD/ --nv sif/helixer.sif Helixer.py \
	--subsequence-length 213840 \
	--overlap-offset 106920 \
	--overlap-core-length 160380 \
	--batch-size ${batch_size} \
	--lineage ${lineage} \
	--temporary-dir ${TMP} \
	--species ${species} \
	--model-filepath ${model} \
	--fasta-path ${genome} \
	--gff-output-path ${out_gff}

grep -v "#" ${out_gff} | awk '$3=="mRNA" || $3=="CDS"' |  awk -F "[;\t]" '{if ($3~/mRNA/) print $0"\t"$9";"; else print $0"\t"$10";" }' | cut -f 1-8,10 > tmp.gff
fix_mRNA_coordinate.pl tmp.gff helixer.bgi.gff
gffread helixer.bgi.gff -g ${genome} -x helixer.bgi.gff.cds -y helixer.bgi.gff.pep
rm -rf tmp.gff ${TMP}
