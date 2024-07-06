## 这种merge方法更有利于对不同数据组装出来的基因组进行merge，以达到对所有的数据都利用起来的效果；
## 假如所有的组装方法都使用了相同的数据那么效果将不明显。

ref_genome=$1
qur_genome=$2
threads=$3

nucmer -t ${threads} -l 100 --mum -p nd ${ref_genome} ${qur_genome}
delta-filter -r -q -l 10000 nd.delta > nd.rq.delta
quickmerge -d nd.rq.delta -q ${qur_genome} -r ${ref_genome} -hco 5.0 -c 1.5 -l 1600000 -ml 10000 -p nd
