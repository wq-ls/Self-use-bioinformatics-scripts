genome=EFGH.fa
pep=pep.fa
prefix=EFGH_                  ### prefix for IDs in GFF3
cpu=20
max_intron_size=10k            ### max intron size [200k]
splice_model=1                  ### splice model: 2=mammal, 1=general, 0=none (see Detail) [1]
weight_of_splice_penalty=1      ### weight of splice penalty; 0 to ignore splice signals [1]

miniprot -G ${max_intron_size} -j ${splice_model} -t ${cpu} --gff -P ${prefix} -C ${weight_of_splice_penalty} ${genome} ${pep} --outs=0.99 > EFGH.gff

grep -A 1 "##PAF" EFGH.gff | awk '$1!~/--/' | paste - - | awk '($5-$4)/$3>0.9' | awk '{print $2"\t"$3"\t"$4"\t"$5"\t"$(NF-10)"\t"$(NF-6)"\t"$(NF-5)"\t"$(NF-4)"\t"$(NF-2)}' | sed 's/;/\t/g;s/ID=//g' > filter.info
cat EFGH.gff | grep -v -e "^#" -e stop_codon | gffread -C -G -K -Q -Y -M --cset -d dup.log -H -V -P -N -Z - -g ${genome} -o EFGH.gff.gffread
fishInWinter.pl -bf table -ff gff - EFGH.gff.gffread | awk '{print $0";"}' | sed "s/miniprot/miniprot_EFGH/1" > EFGH.gff.gffread.gff
Covert_for_evm.pl EFGH.gff.gffread.gff miniprot_EFGH > EFGH.gff.gffread.gff.forevm.gff3
