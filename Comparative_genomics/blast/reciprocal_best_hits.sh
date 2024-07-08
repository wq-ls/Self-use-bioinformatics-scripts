### https://github.com/glarue/reciprologs
### https://rdrr.io/github/drostlab/homologr/man/diamond_reciprocal_best_hits.html

### !!!!!!!!!!
### Attention: cp pep.fa workdir/ !!!!!!! Don't link !!!!!!!! Or blast_db will be generated in raw pep.fa dir !!!!!
### !!!!!!!!!!

### mmseqs  1:1 or 1:many
mmseqs easy-rbh cse.pep dre.pep mmseqs.rbh.txt tmp --threads 5
cut -f 1,2 mmseqs.rbh.txt | awk 'NR==FNR{a[$1]=$0}NR!=FNR{print $0"\t"a[$1]}' cse.gene - | csvtk -t cut -f 2,1,5 - | guanlian2 dre.gene - | csvtk -t cut -f 2,1,3,6- > mmseqs.rbh.txt.diff

### blast_rbh.py
blast_rbh.py --threads=5 -c 30 -i 50 -a prot -t blastp -o blast_rbh.tsv cse.pep dre.pep

### reciprologs && diamond && networkx
reciprologs -p 5 --chain -q 30 -o diamond.rbh.txt --one_to_one --logging cse.pep dre.pep diamondp
#reciprologs -p 10 --chain -q 30 -o diamond_more.rbh.txt cse.pep dre.pep diamondp

### reciprologs && blastp && networkx
reciprologs -p 10 --chain -q 30 -o BLASTP.rbh.txt --one_to_one --logging cse.pep dre.pep blastp

### diamond && evalue
diamond_rbh.R -a cse.fa -b dre.fa -c 10 -e 1E-3 -m 5 -M ultra-sensitive -o diamond.R.rbh.csv
