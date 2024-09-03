export PATH="/01_soft/kmerDedup/:$PATH"

prefix=YZ
cpu=5
work_dir=$PWD/..
input_dir=${work_dir}/split
output_dir=${work_dir}/mapping

[ -d ${output_dir} ] || mkdir ${output_dir}
bowtie2 --very-sensitive -k 1000 --score-min L,-0.6,-0.2 --end-to-end --reorder -L 21 --rg-id ${prefix} --rg SM:${prefix} -p ${cpu} -f ${input_dir}/ABCD -x ${work_dir}/${prefix}.format | samtools view -@ ${cpu} -F 4 -bS - > ${output_dir}/ABCD.bam
