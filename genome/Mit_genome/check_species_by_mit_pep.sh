input_mit_pep=test.pep
cpu=48
evalue=0.0001
matrix=BLOSUM62
query_cover=30
subject_cover=30
database=mitochondrion

## https://ftp.ncbi.nlm.nih.gov/refseq/release/mitochondrion/
## https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/ 
## https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/

### index 
# diamond makedb --in mitochondrion.1.protein.faa -d mitochondrion --taxonnodes nodes.dmp --taxonnames names.dmp --taxonmap prot.accession2taxid.gz

diamond blastp -d ${database} -q ${input_mit_pep} -o ${input_mit_pep}.guess_sp.txt -p ${cpu} --ultra-sensitive --evalue ${evalue} --quiet --matrix ${matrix} --masking 1 --comp-based-stats 1 --max-hsps 0 --query-cover ${query_cover} --subject-cover ${subject_cover} --outfmt 6 qseqid sseqid evalue pident staxids sscinames sphylums

sort -k 1,1 -k 4nr,4 ${input_mit_pep}.guess_sp.txt | awk '!a[$1]++{print $0}' > ${input_mit_pep}.guess_sp2.txt
