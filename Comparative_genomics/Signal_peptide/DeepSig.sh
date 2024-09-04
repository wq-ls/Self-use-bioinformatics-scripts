### https://github.com/BolognaBiocomp/deepsig
# micromamba activate DeepPeptide

source activate /home_micromamba/envs/DeepPeptide
export DEEPSIG_ROOT=/01_software/deepsig

input_pep=FBG.correct.gff.pep
output_txt=FBG.correct.gff.pep.deepsig
organism=euk                ## euk;gramp,gramn    The organism the sequences belongs to.
outfmt=gff3                 ## json;gff3

/usr/bin/singularity exec --bind $PWD/:$PWD/ /01_soft/singularity_all/deepsig.sif deepsig.py -f ${input_pep} -o ${output_txt} -k ${organism} -m ${outfmt}
