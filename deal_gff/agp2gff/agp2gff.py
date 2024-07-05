import sys
from collections import defaultdict

def agp(agp_file):
    agp_dict = defaultdict(list)
    with open(agp_file) as f:
        for line_raw in f:
            line = line_raw.strip().split()
            if line_raw.startswith("#") or line[4] == "N":
                continue
            hic_scaffold,hic_start,hic_end,*ignore,scaffold,sca_start,sca_end,strand=line
            agp_dict[scaffold].append([[int(sca_start),int(sca_end)],hic_scaffold,int(hic_start),strand])
    return agp_dict

def agp2gff(gff_file,agp_dict):
    out_new_gff = open("new_gff.txt","w")
    break_gene = open("break_gene.txt","w")
    not_in_cprops = open("not_in_cprops.txt","w")
    print('##gff-version 3', file=out_new_gff)
    with open(gff_file) as f:
        flag_gene = 1
        for line_raw in f:
            if line_raw.startswith('#'):
                continue
            line = line_raw.strip().split('\t')
            scaffold = line[0]
            gene_start,gene_end = (int(line[3]),int(line[4]))
            gene_strand = line[6]
            gene_type = line[2].lower()
            if scaffold in agp_dict:
                flag = 0
                for l in agp_dict[scaffold]:
                    ScaInAgp_start = l[0][0]
                    ScaInAgp_end = l[0][1]
                    if gene_type == "mrna":
                        flag_gene = 1
                    if gene_start >= ScaInAgp_start and gene_end <= ScaInAgp_end and flag_gene == 1:
                        _,hic_scaffold,hic_start,hic_strand = l
                        line[0] = hic_scaffold
                        line[6] = "+" if gene_strand == hic_strand else "-"
                        #如果agp和gff中链的方向相同，则new.gff中应为正链；否则为负链
                        if hic_strand == "-":
                            gene_true_start = hic_start + ScaInAgp_end - gene_end
                            gene_true_end = gene_true_start + gene_end - gene_start
                        else:
                            gene_true_start = hic_start + gene_start - ScaInAgp_start
                            gene_true_end = gene_true_start + gene_end - gene_start
                        #如果agp文件中为负链，则基因在HiC_scaffold中的起始和终止应正好反向互补，即scaffold的终止位置减去基因的终止位置加上hic的起始位置
                        line[3] = str(gene_true_start)
                        line[4] = str(gene_true_end)
                        print("\t".join(line),file=out_new_gff)
                        flag = 1
                if flag == 0:
                    if gene_type == "mrna":
                        flag_gene = 0
                    print(scaffold,gene_start,gene_end,"is not in ",[l[0] for l in agp_dict[scaffold]],file=break_gene)
#                    print("Error:","gene is not in",scaffold,str(gene_start),str(gene_end))
            else:
                print(scaffold,"is not in cprops",file=not_in_cprops)
#                print("Error:",scaffold,"is not in agp file")

if not sys.argv[1:]:
    sys.stderr.write('Usage: {} agp gff\n'.format(__file__))
    sys.exit()
agp_dict=agp(sys.argv[1])
agp2gff(sys.argv[2],agp_dict)
