### https://github.com/JiaoLaboratory/CRAQ.git
### https://mp.weixin.qq.com/s/Qqj6AlgyImW9U9tTKF-3Cw

### AQI > 90, reference quality; AQI from 80-90, high quality; AQI from 60-80, draft quality; and AQI < 60, low quality.

genome=YZ.asm.hic.p_ctg.fasta
sms_fq=yz.fastq.gz
ngs_fq=YZ-C-3_R1.fq.gz,YZ-C-3_R2.fq.gz
cpu=20
outdir=Result_CRAQ

/01_soft/CRAQ/bin/craq -g ${genome} -sms ${sms_fq} -ngs ${ngs_fq} -x map-hifi --plot T --break T --thread ${cpu} --output_dir ${outdir}

### Get user-specified regional(i.e. window=50000) AQI score.
cat ${outdir}/runAQI_out/strER_out/out_final.CSE.bed ${outdir}/runAQI_out/locER_out/out_final.CRE.bed > ${outdir}/runAQI_out/CRE_CSE.bed
window=50000
perl /01_soft/CRAQ/src/regional_AQI.pl ${outdir}/seq.size ${window} ${window} ${outdir}/runAQI_out/CRE_CSE.bed > ${outdir}/runAQI_out/plot_AQI.out
### plot.  the scaffolds ids you want to present is ok. see CRAQcircos.py --help
python /01_soft/CRAQ/src/CRAQcircos.py --genome_size ${outdir}/seq.size --genome_error_loc ${outdir}/runAQI_out/CRE_CSE.bed --genome_score ${outdir}/runAQI_out/plot_AQI.out --output ${outdir}/runAQI_out/plot_AQI.out.pdf

### !!!! remove intermediate files !!!!
# rm -rf ${outdir}/SRout/*sort* ${outdir}/SRout/*tmp ${outdir}/SRout/Nonmap.loc ${outdir}/LRout/*sort* ${outdir}/LRout/Nonmap.loc
