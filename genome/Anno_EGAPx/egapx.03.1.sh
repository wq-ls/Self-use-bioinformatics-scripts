#!/bin/bash
## source python env with PyYAML Module in
source /01_soft/egapx/egapx/bin/activate

## You can use singularity to pull the img for https://hub.docker.com/r/ncbi/egapx/tags, then put the ncbi-egapx-0.2-alpha.img in NXF_SINGULARITY_CACHEDIR
export NXF_SINGULARITY_CACHEDIR=/01_soft/egapx-0.3.1-alpha/NXF_SINGULARITY_CACHEDIR
export JAVA_HOME=/01_software/jdk-11.0.1
export TMPDIR=$PWD

file_path=local2.yaml
outdir=Output
main_script=/01_soft/egapx-0.3.1-alpha/ui/egapx.py
workdir=$PWD/workdir

[ -d egapx_config ] || mkdir -p egapx_config && cp /01_soft/egapx/egapx_config/singularity.config egapx_config/singularity.config

### the cache file you can download from https://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/EGAP/support_data/
python3 ${main_script} ${file_path} -e singularity -w ${workdir} -o ${outdir} -lc /01_soft/egapx-0.3.0-alpha/support_data

## rm tmp
rm -rf ${workdir} .nextflow
