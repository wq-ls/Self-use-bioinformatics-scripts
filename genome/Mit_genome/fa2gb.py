#!/01_software/miniconda3/bin/python3

import sys
import getopt
sys.path.append('/01_software/miniconda3/lib/python3.7/site-packages/')
from Bio import SeqIO

input_handle = open(sys.argv[1], "r")
output_handle = open(sys.argv[2], "w")

sequences = list(SeqIO.parse(input_handle, "fasta"))

# assign molecule type
for seq in sequences:
  seq.annotations['molecule_type'] = 'DNA'

count = SeqIO.write(sequences, output_handle, "genbank")

output_handle.close()
input_handle.close()
