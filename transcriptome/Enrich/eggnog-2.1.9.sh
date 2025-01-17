## GO and KEGG annotation using diamond by eggnog-mapper
### 1. make XXX.wego to GO-enrich
### 2. make XXX.KO to KEGG-enrich
### 3. make gene symbol annotation file
### Attention!!!  qsub vf>8G

# source /dellfsqd2/ST_OCEAN/USER/lishuo1/11_env/bashrc-17-1.txt
export PATH="/01_software/eggnog-mapper-2.1.9/eggnogmapper/bin:$PATH"

query=$PWD/H_moli.bgi.gff.pep
cpu=10
out_name=eggnog-result
output_dir=$PWD
temp_dir=$PWD
database=/01_software/eggnog-mapper-2.1.4-main_spec/data/
main_script=/01_software/eggnog-mapper-2.1.9/emapper.py
software=diamond   ## diamond,mmseqs,hmmer
evalue=0.001
sensmode=ultra-sensitive     ## for diamond: fast,mid-sensitive,sensitive,more-sensitive,very-sensitive,ultra-sensitive

/01_software/miniconda3/bin/python3 $main_script --cpu $cpu --data_dir $database -o $out_name --output_dir $output_dir --temp_dir $temp_dir --override -m $software -i $query --tax_scope auto --target_orthologs all --go_evidence all --pfam_realign none --report_orthologs --decorate_gff yes --evalue ${evalue} --scratch_dir $PWD --sensmode ${sensmode}

grep -v -e "#" -e "query" *.emapper.annotations | awk -F "\t" '{print $1"\t"$10}' | sed 's/"//g;s/-//g;s/,/\t/g' > anno.wego
grep -v -e "#" *.emapper.annotations  | awk -F "\t" '{print $1"\t"$9"\t"$NF"\t"$8}' | sed 's/"//g' > simple.anno
grep -v -e "#" -e "query" *.emapper.annotations | awk -F "\t" '{print $1"\t"$10}' | awk '$2!~/-/' | sed 's/"//g;s/,/;/g;s/\t/,/g' | /lishuo1/00_tools/csvtk unfold -H -f 2 -s ";" | sed 's/,/\t/g' > anno.unfold.wego
grep -v -e "#" -e "query" *.emapper.annotations | awk -F "\t" '{print $1"\t"$12}' | awk '$2!~/-/' | sed 's/ko://1;s/,ko:/;/g;s/\t/,/g' | /lishuo1/00_tools/csvtk unfold -H -f 2 -s ";" | sed 's/,/\t/g' > anno.unfold.KO
grep -v -e "#" -e "query" *.emapper.annotations | awk -F "\t" '{print $1"\t"$12}' | awk '$2!~/-/' | sed 's/ko://1;s/,ko:/,/g' > anno.fold.KO
/01_software/miniconda3/bin/python /01_soft/kofam_scan-1.3.0/kofamscan_plus.py -K /01_soft/kofam_scan-1.3.0/ko00001.keg -i anno.unfold.KO -o kegg.all.xls
awk -F "\t" '{print $1"\t"$4"\t"$5}' kegg.all.xls > gene2pathway.txt
cut -f 1,3 kegg.all.xls | sed '1d;s/; /;/g' | awk -F "\\\[EC" '{print $1}' | awk '!a[$0]++' | /lishuo1/00_tools/csvtk -t fold -H -f 1 -v 2 -s " ||| " | awk -F "\t" 'NR==FNR{a[$1]=$2}NR!=FNR{print $0"\t"a[$1]}' - simple.anno | /lishuo1/00_tools/csvtk -t add-header -n ID,Symbol,Domain,Description,Symbol_KEGG > simple.anno.new
rm simple.anno

### 注释结果说明：eggnog-mapper会生成三个文件
### [project_name].emapper.hmm_hits:  记录每个用于搜索序列对应的所有的显著性的eggNOG Orthologous Groups(OG). 所有标记为"-"则表明该序列未找到可能的OG
### [project_name].emapper.seed_orthologs: 记录每个用于搜索序列对的的最佳的OG，也就是[project_name].emapper.hmm_hits里选择得分最高的结果。之后会从eggNOG中提取更精细的直系同源关系(orthology relationships)
### [project_name].emapper.annotations: 该文件提供了最终的注释结果。大部分需要的内容都可以通过写脚本从从提取，一共有13列。[project_name].emapper.annotations每一列对应的记录如下：
### query_name: 检索的基因名或者其他ID
### sedd_eggNOG_ortholog: eggNOG中最佳的蛋白匹配
### seed_orholog_evalue: 最佳匹配的e-value
### seed_ortolog_evalu: 最佳匹配的bit-score
### predicted_gene_name: 预测的基因名，特别指的是类似AP2有一定含义的基因名，而不是AT2G17950这类编号
### GO_term: 推测的GO的词条， 未必最新
### KEGG_KO: 推测的KEGG KO词条， 未必最新
### BiGG_Reactions: BiGG代谢反应的预测结果
### Annotation_tax_scope: 对该序列在分类范围的注释
### Matching_OGs: 匹配的eggNOG Orthologous Groups
### best_OG|evalue|score: 最佳匹配的OG(HMM模式才有)
### COG functional categories: 从最佳匹配的OG中推测出的COG功能分类
### eggNOG_HMM_model_annotation: 从最佳匹配的OG中推测出eggNOG功能描述
