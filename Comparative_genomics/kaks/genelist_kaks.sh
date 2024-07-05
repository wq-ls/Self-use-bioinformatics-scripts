#!/bin/bash

if [[ $# == '0' ]]; then
    echo "             This shell for calculate Ka/Ks by a given gene list"
    echo "usage:      sh genelist_kaks.sh genelist cpu outdir_tmp all.pep all.cds"
    echo " "
    echo "example:    sh genelist_kaks.sh tlr9_gene 6 test_dir all.pep all.cds "
    echo " "
    echo "attention:  1. The outdir_tmp is automatically generated! "
    echo "            2. Change different outdir_tmp name before using it !!! "
    exit 1
fi

### change parameter name
GO_term=$1
cpu=$2
outdir_tmp=$3
all_pep=$4
all_cds=$5

### software
seqtk=/bin/seqtk
ParaAT=/bin/ParaAT.pl
${blast_shell}=blast.sh

### step1: get gene list
cp ${GO_term} ${GO_term}.all.gene.list

### step2: get cds & pep
${seqtk} subseq ${all_cds} ${GO_term}.all.gene.list > ${GO_term}.all.gene.list.cds
${seqtk} subseq ${all_pep} ${GO_term}.all.gene.list > ${GO_term}.all.gene.list.pep

### step3: blastn and get gene pair
sh  ${GO_term}.all.gene.list.cds ${GO_term}.all.gene.list.cds nucl blastn result.txt ${cpu}
grep -v "#" result.txt | awk '$9/$8>0.6||$9/$7>0.6' | cut -f 1,4 | awk '$1!=$2' | awk '!a[$1,$2] && !a[$2,$1]++' > ${GO_term}.gene.pair

### step4: make cpu file
echo ${cpu} > procpu

### step5: calculate Ka/Ks
${ParaAT} -h ${GO_term}.gene.pair -n ${GO_term}.all.gene.list.cds -a ${GO_term}.all.gene.list.pep -m clustalw2 -p procpu -f axt -g -k -o ${outdir_tmp}

### step6: deal output
cat ./${outdir_tmp}/*kaks |awk 'NR==1;NR>=1 { print $0| "grep -v Sequence"}' > ${GO_term}.all.kaks.result.xls
#less all.kaks.result.xls  |cut -f 5|grep -v 'NA' > kaks.list

### step7: remove tmpfile
rm -rf *all.gene.list* blastdb procpu ${outdir_tmp} result.txt

### ParaAT.pl help
# ParaAT.pl -h test.homologs -n test.cds -a test.pep -p proc -o output -f axt
#--------------------------------
#-h, 指定同源基因列表文件
#-n, 指定核酸序列文件
#-a, 指定蛋白序列文件
#-p, 指定多线程文件                      ## 文件中给定线程数，默认为6
#-m, 指定比对工具                        ## muscle
#-g, 去除比对有gap的密码子
#-k, 用KaKs_Calculator                   ## 计算kaks值
#-o, 输出结果的目录
#-f, 输出比对文件的格式
