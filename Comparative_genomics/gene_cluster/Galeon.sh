#!/bin/bash
## https://github.com/molevol-ub/galeon
# micromamba activate Galeon
source activate /micromamba/envs/Galeon

export PATH=/01_soft/galeon/GALEON_masterScripts:$PATH
export PATH=/mambaforge/envs/R-4.2/bin/:$PATH

genome=fcs.fa
EVM=fcs.EVM.bgi.filter.gff
ID=dom.select.id
famliy_name=FRED
GVALUE=100	## ## 软件估计在多个碱基中发现的预期基因数量，以及在g输入值中预期的基因数量，并估计在 GVALUE 大小（即：GVALUE Kb）的窗口中发现2个或更多基因的概率，在以下分析中，这些基因将被视为一个簇.
cpu=48

fishInWinter.pl ${ID} ${EVM} > ${ID}.gff
gffread ${ID}.gff -g ${genome} -x ${ID}.gff.cds -y ${ID}.gff.pep

[ -d GFFs ] || mkdir GFFs
[ -d Proteins ] || mkdir Proteins

awk '$3=="mRNA"' ${ID}.gff | cut -f 1,4,5,9 | sed 's/ID=//g;s/;//g' > GFFs/${famliy_name}_fam.bed2
sed "s/U$//g" ${ID}.gff.pep > Proteins/${famliy_name}_fam.fasta

mafft --auto --thread ${cpu} ${ID}.gff.pep > Proteins/${famliy_name}_fam.aln

GALEON_ControlScript.py clusterfinder -a GFFs/ -p Proteins/ -e enabled -pm True -F WithinFamilies -g ${GVALUE} -emx_pos Lower -c two -t FastTree -f orange -outdir cluster_${famliy_name} -log Log_dir

GALEON_GetEvoStats.py -clust cluster_${famliy_name} -prot Proteins/ -coords GFFs

perl /dellfsqd2/ST_OCEAN/USER/lishuo11/01_soft/galeon/GALEON_masterScripts/Scripts/Get_scaffold_length.pl ${genome}

## -sfilter ALL|NUM|FILE The summary plots will represent the results for a "NUM" number of largest scaffolds; a list of scaffolds of interest provided as a single column in an input "FILE"; "ALL" the scaffolds (often too many, the resulting summary plots might not informative).

GALEON_SummaryFiles.py -fam ${famliy_name} -clust cluster_${famliy_name} -coords GFFs -ssize ChrSizes.txt -sfilter 10
