
genus=Hypophthalmichthys
species=nobilis
taxid=7965
name=lishuo
gene2path=gene2pathway.txt

## EggNog annotation file and gene2pathway.txt
sed '1,4d' eggnog-result.emapper.annotations | sed 's/^#//g' | grep -v "#" | csvtk replace -t -F -f "GOs" -p "(-)" -r "NA" | csvtk replace -t -F -f "KEGG_ko" -p "(-)" -r "NA" | csvtk replace -t -F -f "KEGG_Pathway" -p "(-)" -r "NA" | csvtk replace -t -F -f "eggNOG_OGs" -p "(-)" -r "NA" > eggNog.anno.txt

/micromamba/envs/R_env/bin/Rscript AnnotationForge_20250117.R -i eggNog.anno.txt -a ${name} -m shiyeyishang@outlook.com -g ${genus} -s ${species} -d ${taxid}
DB=$(ls | grep eg.db)
sed -i 's/shiyeyishang\@outlook.com/lishuo \<shiyeyishang\@outlook.com\>/g' ${DB}/DESCRIPTION
/dellfsqd2/ST_OCEAN/USER/lishuo11/09_test/zz_tmp/home_micromamba/envs/R_env/bin/R CMD build $DB

[ -d R_lib ] || mkdir R_lib
DBgz=$(ls | grep eg.db | grep "tar.gz")
/micromamba/envs/R_env/bin/R CMD INSTALL ${DBgz} --library=$PWD/R_lib

## deal gene2pathway.txt
sed '1d' ${gene2path} | csvtk -t add-header -n GID,Pathway,Name > gene2pathway_forClusterProfiler.txt

rm -rf ${DB} ${DBgz} eggNog.anno.txt
