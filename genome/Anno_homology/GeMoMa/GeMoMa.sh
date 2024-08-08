jar=GeMoMa-1.9.jar

target_genome=ABCD.fa
pep=all.pep.cdhit.fa
threads=5
out=GeMoMa

java -Xms5G -Xmx10G -jar ${jar} CLI GeMoMaPipeline threads=${threads} AnnotationFinalizer.r=NO p=false o=true t=$target_genome outdir=$out s=pre-extracted c=$pep
