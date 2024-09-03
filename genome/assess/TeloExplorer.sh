
genome=Juicer.FINAL.fa
type_use=animal
prefix=Telo

quartet.py TeloExplorer -i ${genome} -c ${type_use} -p ${prefix}
mv tmp ${prefix}_detail
