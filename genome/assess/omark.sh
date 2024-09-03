#https://github.com/DessimozLab/OMArk
### Attention!!! ###
## before run OMArk, mkdir .etetoolkit in your home dir.

input=EFGH
outdir=omark_assess
database=/06_database/OMArk_database/LUCA.h5

[ -d ${outdir} ] || mkdir -p ${outdir}

##  source activate /micromamba/envs/OMArk
# omamer -h
# omark -h

/01_soft/mambaforge/bin/micromamba run -n OMArk omamer search --db ${database} --query ${input} --out ${outdir}/${input}.omamer
/01_soft/mambaforge/bin/micromamba run -n OMArk omark -f ${outdir}/${input}.omamer -d ${database} -o ${outdir}
