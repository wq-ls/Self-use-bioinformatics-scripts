
indir=data
houzhui=.fa
cpu=10
path_fasttree=/00_tools/FastTree
path_diamond=/00_tools/diamond

broccoli.py -dir ${indir} -ext ${houzhui} -threads ${cpu} -path_diamond ${path_diamond} -path_fasttree ${path_fasttree}

<<!!!
 general options:
  -steps             steps to be performed, comma separated (default = '1,2,3,4')
  -threads           number of threads [default = 1]
  -h, -help          show this help message and exit


 STEP 1  kmer clustering:
  -dir               name of the directory containing the proteome files [required]
  -ext               extension of proteome files (default = '.fasta')
  -kmer_size         length of kmers [default = 100]
  -kmer_min_aa       minimum nb of different aa a kmer should have [default = 15]

 STEP 2  phylomes:
  -path_diamond      path of DIAMOND with filename [default = 'diamond']
  -path_fasttree     path of FastTree with filename [default = 'fasttree']
  -e_value           e-value for similarity search [default = 0.001]
  -nb_hits           max nb of hits per species [default = 6]
  -max_gap           max fraction of gap per position [default = 0.7]
  -phylogenies       phylogenetic method: 'nj' (neighbor joining), 'me' (minimum evolution) or 'ml' (maximum likelihood) [default = 'nj']

 STEP 3  network analysis:
  -sp_overlap        max ratio of overlapping species in phylogenetic trees [default = 0.5]
  -min_weight        min weight for an edge to be kept in the orthology network [default = 0.1]
  -min_nb_hits       spurious hits: min number of hits belonging to the OG [default = 2]
  -chimeric_shared   chimeric prot: min fraction of connected nodes in each OG [default = 0.5]
  -chimeric_nb_sp    chimeric prot: min nb of species in OGs involved in gene-fusions [default = 3]

 STEP 4  orthologous pairs:
  -ratio_ortho       limit ratio ortho/total [default = 0.5]
  -not_same_sp       ignore ortho relationships between proteins of the same species (QfO benchmark)
!!!
