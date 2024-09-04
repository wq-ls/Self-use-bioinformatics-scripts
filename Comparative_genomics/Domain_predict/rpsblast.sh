pep=all.deal.pep
cpu=38
evalue=0.01
database_dir=/06_database/CDD_db

### for i in {CdD,Tigr,Prk,Pfam,Kog,Cog,Cdd_NCBI,ncbi.cdd}; do grep -e "pep=" -e "cpu=" -e "evalue=" -e "database_dir=" -e ${i} rpsblast.sh > rpsblast.${i}.sh; done

rpsblast -query ${pep} -outfmt 6 -evalue ${evalue} -db ${database_dir}/Cdd  -out CdD_${pep}.txt -num_threads ${cpu}
rpsblast -query ${pep} -outfmt 6 -evalue ${evalue} -db ${database_dir}/Tigr  -out Tigr_${pep}.txt -num_threads ${cpu}
rpsblast -query ${pep} -outfmt 6 -evalue ${evalue} -db ${database_dir}/Prk  -out Prk_${pep}.txt -num_threads ${cpu}
rpsblast -query ${pep} -outfmt 6 -evalue ${evalue} -db ${database_dir}/Pfam  -out Pfam_${pep}.txt -num_threads ${cpu}
rpsblast -query ${pep} -outfmt 6 -evalue ${evalue} -db ${database_dir}/Kog  -out Kog_${pep}.txt -num_threads ${cpu}
rpsblast -query ${pep} -outfmt 6 -evalue ${evalue} -db ${database_dir}/Cog  -out Cog_${pep}.txt -num_threads ${cpu}
rpsblast -query ${pep} -outfmt 6 -evalue ${evalue} -db ${database_dir}/Cdd_NCBI  -out Cdd_NCBI_${pep}.txt -num_threads ${cpu}
rpsblast -query ${pep} -outfmt 6 -evalue ${evalue} -db ${database_dir}/ncbi.cdd  -out ncbi.cdd_${pep}.txt -num_threads ${cpu}

cat CdD_${pep}.txt | awk '{if ($7<$8) print $1"\t"$7"\t"$8"\t"$0; else print $1"\t"$8"\t"$7"\t"$0}' | sort -k 1,1 -k 2n,2 | bedtools cluster -i - | sort -k 16n,16 -k 15nr,15 | awk '!a[$16]++{print $0}' | csvtk cut -t -f 5,1,2,3 | sed 's/CDD://g' |  awk 'NR==FNR{a[$1]=$0}NR!=FNR{print $0"\t"a[$1]}' ${database_dir}/cddid_all.tbl - | cut -f 2-4,6- > Cdd.dom
cat Tigr*txt | awk '{if ($7<$8) print $1"\t"$7"\t"$8"\t"$0; else print $1"\t"$8"\t"$7"\t"$0}' | sort -k 1,1 -k 2n,2 | bedtools cluster -i - | sort -k 16n,16 -k 15nr,15 | awk '!a[$16]++{print $0}' | csvtk cut -t -f 5,1,2,3 | sed 's/CDD://g' |  awk 'NR==FNR{a[$1]=$0}NR!=FNR{print $0"\t"a[$1]}' ${database_dir}/cddid_all.tbl - | cut -f 2-4,6- > Tigr.dom
cat Prk*txt | awk '{if ($7<$8) print $1"\t"$7"\t"$8"\t"$0; else print $1"\t"$8"\t"$7"\t"$0}' | sort -k 1,1 -k 2n,2 | bedtools cluster -i - | sort -k 16n,16 -k 15nr,15 | awk '!a[$16]++{print $0}' | csvtk cut -t -f 5,1,2,3 | sed 's/CDD://g' |  awk 'NR==FNR{a[$1]=$0}NR!=FNR{print $0"\t"a[$1]}' ${database_dir}/cddid_all.tbl - | cut -f 2-4,6- > Prk.dom
cat Pfam*txt | awk '{if ($7<$8) print $1"\t"$7"\t"$8"\t"$0; else print $1"\t"$8"\t"$7"\t"$0}' | sort -k 1,1 -k 2n,2 | bedtools cluster -i - | sort -k 16n,16 -k 15nr,15 | awk '!a[$16]++{print $0}' | csvtk cut -t -f 5,1,2,3 | sed 's/CDD://g' |  awk 'NR==FNR{a[$1]=$0}NR!=FNR{print $0"\t"a[$1]}' ${database_dir}/cddid_all.tbl - | cut -f 2-4,6- > Pfam.dom
cat Kog*txt | awk '{if ($7<$8) print $1"\t"$7"\t"$8"\t"$0; else print $1"\t"$8"\t"$7"\t"$0}' | sort -k 1,1 -k 2n,2 | bedtools cluster -i - | sort -k 16n,16 -k 15nr,15 | awk '!a[$16]++{print $0}' | csvtk cut -t -f 5,1,2,3 | sed 's/CDD://g' |  awk 'NR==FNR{a[$1]=$0}NR!=FNR{print $0"\t"a[$1]}' ${database_dir}/cddid_all.tbl - | cut -f 2-4,6- > Kog.dom
cat Cog*txt | awk '{if ($7<$8) print $1"\t"$7"\t"$8"\t"$0; else print $1"\t"$8"\t"$7"\t"$0}' | sort -k 1,1 -k 2n,2 | bedtools cluster -i - | sort -k 16n,16 -k 15nr,15 | awk '!a[$16]++{print $0}' | csvtk cut -t -f 5,1,2,3 | sed 's/CDD://g' |  awk 'NR==FNR{a[$1]=$0}NR!=FNR{print $0"\t"a[$1]}' ${database_dir}/cddid_all.tbl - | cut -f 2-4,6- > Cog.dom
cat Cdd_NCBI*txt | awk '{if ($7<$8) print $1"\t"$7"\t"$8"\t"$0; else print $1"\t"$8"\t"$7"\t"$0}' | sort -k 1,1 -k 2n,2 | bedtools cluster -i - | sort -k 16n,16 -k 15nr,15 | awk '!a[$16]++{print $0}' | csvtk cut -t -f 5,1,2,3 | sed 's/CDD://g' |  awk 'NR==FNR{a[$1]=$0}NR!=FNR{print $0"\t"a[$1]}' ${database_dir}/cddid_all.tbl - | cut -f 2-4,6- > Cdd_NCBI.dom
cat ncbi.cdd*txt | awk '{if ($7<$8) print $1"\t"$7"\t"$8"\t"$0; else print $1"\t"$8"\t"$7"\t"$0}' | sort -k 1,1 -k 2n,2 | bedtools cluster -i - | sort -k 16n,16 -k 15nr,15 | awk '!a[$16]++{print $0}' | csvtk cut -t -f 5,1,2,3 | sed 's/CDD://g' |  awk 'NR==FNR{a[$1]=$0}NR!=FNR{print $0"\t"a[$1]}' ${database_dir}/cddid_all.tbl - | cut -f 2-4,6- > ncbi.cdd.dom
