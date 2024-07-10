对于三代pacbio初组装的基因组来说，三代测序有一定的错误率，组装出的基因组可能会有错误的区域，这时可以选择用所测的三代测序数据和二代测序数据进行基因组草图纠错。
其实在组装时我们也可以用二代和三代数据进行混合组装(等进一步测试后，我会进行补充，目前先不写)
racon用于三代数据纠错，pilon则是运用二代数据纠错，顺便提一下 nextpoilsh 既可以用三代也可以用二代进行纠错，感觉二代纠错质量不如pilon，这里仁者见仁智者见智。
1、软件安装
--------------------------------------------------
#这里推荐用mamba直接进行安装
mamba install pilon
mamba install racon
#这里同样需要其他软件：minimap2 、bwa 这里自行安装
--------------------------------------------------
2、开始进行基因组纠错(每个纠错各需要三轮，先三代后二代)
--------------------------------------------------
#三代第一轮纠错
minimap2  -ax map-pb -t 24 assembly.fa pacbio.read.fasta | gzip -c - > minimap1.sam.gz
racon -t 24 -u pacbio.read.fasta minimap1.sam.gz  assembly.fa >racon1.fasta
#三代第二轮纠错
minimap2  -ax map-pb -t 24 racon1.fasta pacbio.read.fasta | gzip -c - > minimap2.sam.gz
racon -t 24 -u pacbio.read.fasta minimap2.sam.gz racon1.fasta > racon2.fasta
#三代第三轮纠错
minimap2  -ax map-pb -t 24 racon2.fasta pacbio.read.fasta | gzip -c - > minimap3.sam.gz
racon -t 24 -u pacbio.read.fasta minimap3.sam.gz racon2.fasta > racon3.fasta
#二代第一轮纠错
bwa index racon3.fasta
bwa mem -t 24 racon3.fasta illmunia_R1.fq.gz  illmunia_R2.fq.gz |samtools sort -@ 24 - -o bwamem1.bam
pilon  --genome racon3.fasta --frags bwamem1.bam --changes --diploid --outdir ./pilon.out --output pilon1
#二代第二轮纠错
bwa index ./pilon.out/pilon1.fasta 
bwa mem -t 24 ./pilon.out/pilon1.fasta illmunia_R1.fq.gz  illmunia_R2.fq.gz |samtools sort -@ 24 - -o bwamem2.bam
pilon  --genome ./pilon.out/pilon1.fasta --frags bwamem2.bam --changes --diploid --outdir ./pilon.out --output pilon2
#二代第三轮纠错
bwa index ./pilon.out/pilon2.fasta 
bwa mem -t 24 ./pilon.out/pilon2.fasta illmunia_R1.fq.gz  illmunia_R2.fq.gz |samtools sort -@ 24 - -o bwamem3.bam
pilon  --genome ./pilon.out/pilon2.fasta --frags bwamem3.bam --changes --diploid --outdir ./pilon.out --output pilon3
--------------------------------------------------------
