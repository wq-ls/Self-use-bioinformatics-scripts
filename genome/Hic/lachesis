
lachesis 是一个比较老的挂载hic软件，能够有效聚类和排序，现在发表的大部分HiC挂载文章都出自于它。但不适合多倍体和高杂合度的基因组，2017年就不再更新。
lachesis极其难安装建议直接下载docker镜像
1、lachesis镜像下载
-----------------------------------------------------------------------------
/usr/bin/singularity build lachesisi.sif docker://aakashsur/lachesis
-----------------------------------------------------------------------------
2、同时在lachesis的github中下载PreprocessSAMs.pl 、PreprocessSAMs.sh、make_bed_around_RE_site.pl 脚本，chomd 777 开启权限；
   在PreprocessSAMs.pl 修改bedtools samtools make_bed_around_RE_site_pl 路径$RE_site=后面修改自己hic的酶切类型，开始运行：
----------------------------------------------------------------------------------------------------------------------
bwa index assembly.fa
bwa mem -t 10 ./assembly.fa ./HIC_R1.fq.gz ./HIC_R2.fq.gz >prefix.bam
perl PreprocessSAMs.pl prefix.bam assembly.fa # 最后生成prefix.REduced.paired_only.bam 和prefix.REduced.paired_only.flagstat
/usr/bin/singularity exec --bind  /path/：/path/   ./lachesis.sif lachesis  test_case.ini
-----------------------------------------------------------------------------------------------------------------------
test_case.ini为配置文件，可以在lachesis的github中自行下载并自行修改，以下为我的配置文件范例(需要更改的参数会在后面有#注释，其他为默认参数)
-----------------------------------------------------------------------------------------------------------------------
# Species.  If assembling a species for which there is already a reference, use "human" or "mouse" or "fly"; these names are hard-wired into the code.
# If assembling any other species (including e.g., other Drosophila species), DO NOT use these strings.
SPECIES = fish   #写自己实际的物种名称就可以


# Directory which will contain the output.  When Lachesis is run, it will create this directory, along with subdirectories main_results/ and cached_data/.
# If DO_REPORTING = 1 below, the file REPORT.txt, which is the main output reporting file, will be created in here.
OUTPUT_DIR = out/test_case   #结果输出的路径



#################################################
#
#   PARAMETERS FOR THE INPUT ASSEMBLY
#

# Draft assembly fasta file.
DRAFT_ASSEMBLY_FASTA = ./s_trutta.hifiasm_v19.fa  #自己初步组装的基因组，防止报错建议写绝对路径

# Directory containing the input SAM/BAM files that describe Hi-C read alignments to the draft assembly.
# This directory path can be absolute, or relative to the directory in which Lachesis is run.  This should be listed before SAM_FILES.
SAM_DIR = ./ #所跑出bam文件的路径

# The input SAM/BAM files that describe Hi-C read alignments to the draft assembly.
# These files should exist in SAM_DIR, above, and they should already be pre-processed (e.g., to remove PCR duplicates) and sorted by read name (not by order).
# If any of these files fails to exist, Lachesis won't run.
SAM_FILES = fish.REduced.paired_only.bam
# Use a reference genome?  Options: 0 (false), 1 (true).
USE_REFERENCE = 0 #如果组装的物种没有参考的基因组则次参数改为0，如果有则为1

# If the draft assembly is just the reference genome chopped into simulated bins (e.g., Table 2 in the original Lachesis publication) put the bin size here.
# Otherwise set to 0.  Note that this must be set to 0 if SPECIES is set to anything other than "human".
SIM_BIN_SIZE = 0

# Reference assembly fasta file.  Ignored if USE_REFERENCE = 0.
REF_ASSEMBLY_FASTA = test_case/hg19/Homo_sapiens_assembly19.fasta #有参考基因组的话，写参考基因组绝对路径，没有则忽略

# File head for BLAST alignments.  You must align the draft assembly to the reference genome using BLAST (UNIX command: `blastn -outfmt 7 ...`).
# The output should go into a set of one or more files called <BLAST_FILE_HEAD>.*.blast.out, where * = 1,2,3,...
# Lachesis will create a file at <OUTPUT_DIR>/cached_data/TrueMapping.assembly.txt.  Once this file exists, you no longer need the BLAST files.
# Alternatively, if SIM_BIN_SIZE > 0 (above), BLAST_FILE_HEAD is ignored because no alignments to reference are needed.
BLAST_FILE_HEAD = test_case/draft_assembly/assembly #如果有参考基因组在跑lachesis的前一步要添加一部blastn比对，并且文件输出的格式为 'outfmt -7' 文件格式，如果无参考基因组则忽略
DO_CLUSTERING = 1
DO_ORDERING   = 1
DO_REPORTING  = 1

# At the beginning of clustering, the Hi-C links are loaded from the SAM files, and then the cache file <OUTPUT_DIR>/cached_data/all.GLM is created.
# If this cache file already exists, and if OVERWRITE_GLM = 0, the links are loaded from cache, saving time.  Set to 1 if the content of SAM_FILES changes.
OVERWRITE_GLM = 0

# At the beginning of ordering, the links are loaded from the SAM files, and then the cache files <OUTPUT_DIR>/cached_data/group*.CLM are created.
# If these cache files already exist, and if OVERWRITE_CLMS = 0, the links are loaded from cache, saving time.
# Set to 1 if you change anything about the clustering, so that the change will propagate to the ordering.  Otherwise Lachesis will throw an error.
OVERWRITE_CLMS = 0
#################################################
#
#   HEURISTIC PARAMETERS FOR CLUSTERING AND ORDERING
#
#   For these keys, the accepted values are integers and decimal numbers.
#
# Number of clusters.  Set this to the number of chromosomes in the input assembly.
CLUSTER_N = 40  #物种基因组染色体数目
# Mark some contigs as containing CENs (centromeres), which will cause Lachesis not to combine any two of these contigs into a single cluster.
# This is useful in yeast genomes, in which centromere clustering creates a strong Hi-C signal among the CEN-containing contigs which Lachesis will mistake
# for intra-chromosome linkage.  It should be easy to pick out the CEN-containing contigs just by looking at a pre-Lachesis heatmap of the links; for example,
# see https://doi.org/10.1093/bioinformatics/btu162.  The number of contigs listed here can't be greater than CLUSTER_N.
# Specify the contigs by their ID in the input draft assembly (first contig = 0).  To not mark any contigs, set to "-1".
CLUSTER_CONTIGS_WITH_CENS = -1
# Only use contigs as informative for clustering if they have at least this many restriction enzyme (RE) sites.
CLUSTER_MIN_RE_SITES = 90  #推荐此参数为90，此参数为每个CLUSTER所包含的最小酶切数量
# Only use contigs as informative for clustering if they have LESS than this much times the average density of Hi-C links.
# Contigs with too many Hi-C links tend to be in heterochromatin or other repeat-rich regions.
CLUSTER_MAX_LINK_DENSITY = 2
# Non-informative contigs (the ones that fail the CLUSTER_MIN_RE_SITES or CLUSTER_MAX_LINK_DENSITY filters) may be added to groups after clustering is over, if
# they fit cleanly into one group.  "Fitting cleanly" into a group means having at least CLUSTER_NONINFORMATIVE_RATIO times as much linkage into that group as
# into any other.  Set CLUSTER_NONINFORMATIVE_RATIO to 0 to prevent non-informative contigs from being clustered at all; otherwise it must be set to > 1.
CLUSTER_NONINFORMATIVE_RATIO = 3
# Boolean (0/1).  Draw a 2-D heatmap of the entire Hi-C link dataset before clustering.
CLUSTER_DRAW_HEATMAP = 1
# Boolean (0/1).  Draw a 2-D dotplot of the clustering result, compared to truth.  This is time-consuming and eats up file I/O.  Ignored if USE_REFERENCE = 0.
# The dotplots go to ~/public_html/dotplot.SKY.*.jpg
CLUSTER_DRAW_DOTPLOT = 1
# Minimum number of RE sites in contigs allowed into the initial trunk.
ORDER_MIN_N_RES_IN_TRUNK = 120  #推荐此参数为120 
# Minimum number of RE sites in shreds considered for reinsertion.
ORDER_MIN_N_RES_IN_SHREDS = 15
# Boolean (0/1).  If 1, draw a 2-D dotplot for each cluster, showing the ordering results compared to truth.  Ignored if USE_REFERENCE = 0.
ORDER_DRAW_DOTPLOTS = 1
#################################################
#
#   OUTPUT PARAMETERS
#
#   These parameters do not change the results of Lachesis, but they change where and how the results are reported in OUTPUT_DIR.
#

# IDs of groups to exclude from the REPORT.txt numbers (e.g. groups determined to be small, crappy and/or chimeric.)  If not excluding any groups, set to "-1".
REPORT_EXCLUDED_GROUPS = -1
# Quality filter.  Contigs whose orientation quality scores (differential log-likelihoods) are this or greater are considered high-quality.
# The quality scores depend on Hi-C read coverage, so you'll want to try out some values in order to achieve an informative differentiation in REPORT.txt.
REPORT_QUALITY_FILTER = 1
# Boolean (0/1).  If 1, create a Hi-C heatmap of the overall result via the script heatmap.MWAH.R.  This is a useful reference-free evaluation.
REPORT_DRAW_HEATMAP = 1 
-------------------------------------------------------------------------------------------------------------------
