#!/dellfsqd2/ST_OCEAN/USER/lishuo11/01_soft/mambaforge/bin/python3

import sys
gff = sys.argv[1]

with open(gff,'r') as infile:
	with open('mrna_'+gff,'w') as outfile:
		ls_gene = []
		for line in infile:
			chrom = line.split('\t')[0]
			sam = line.split('\t')[1]
			id = line.split('\t')[5]
			info = line.split('\t')[8]
			phase = line.split('\t')[7]
			region = line.split('\t')[2]
			pos_ne = line.split('\t')[6]
			start = line.split('\t')[3]
			end = line.split('\t')[4]
			if region == 'mRNA':
				min = 'NA'
				max = 'NA'
				for ls in ls_gene:
					if ls[2] == 'CDS':
						if min == 'NA' or int(ls[3]) < int(min):
							min = ls[3]
						if max == 'NA' or int(ls[4]) > int(max):
							max = ls[4]
				for ls in ls_gene:
					if ls[2] == 'mRNA':
						ls[3] = min
						ls[4] = max
					outfile.write('\t'.join(ls))
				ls_gene = []				
			ls = [chrom, sam, region, start, end, id, pos_ne, phase, info] 	
			ls_gene.append(ls)
		
		min = 'NA'
		max = 'NA'
		for ls in ls_gene:
			if ls[2] == 'CDS':
				if min == 'NA' or int(ls[3]) < int(min):
					min = ls[3]
				if max == 'NA' or int(ls[4]) > int(max):
					max = ls[4]
		for ls in ls_gene:
			if ls[2] == 'mRNA':
				ls[3] = min
				ls[4] = max
			outfile.write('\t'.join(ls))
	outfile.close()
infile.close()
					
