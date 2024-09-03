#!/bin/bash

####atttention###

# The odb must be odb10.(~/06_database/)
# augustus_species ~/01_software/minimamba/envs/augustus/config/species
#                  ~/06_database/specie.txt

####atttention###

### version 4.1.2
#source activate ~/conda/envs/busco-4/
### version 5.3
#source activate ~/miniconda3/envs/busco5
### version 5.5.0
source activate ~/home_micromamba/envs/busco5.5.0

input=pep.fa
cpu=5
model=prot  ##trans prot geno
output=BUSCO
evalue=1e-03
species_model=zebrafish
db=actinopterygii_odb10
database=/~/06_database

busco --offline -l ${database}/${db} -e ${evalue} -m ${model} -c ${cpu} -i ${input} -o ${output} --augustus_species ${species_model}

rm -rf ${output}/logs/ ${output}/run_${db}/busco_sequences/ ${output}/run_${db}/hmmer_output/ ${output}/short_summary.specific.${db}.BUSCO.json ${output}/run_${db}/short_summary.json busco_downloads
mv ${output}/run_${db}/* ${output}/
rm -rf ${output}/run_${db}
