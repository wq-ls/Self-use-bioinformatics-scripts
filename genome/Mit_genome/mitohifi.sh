#!/bin/bash
set +o posix
set -eo pipefail

ccs_reads=HCS.fasta.gz
close_sp_mit_fa=NC_052743.1.fa
cpu=48
sp=animal
GENETIC_CODE=9   # 1. The Standard Code, 2. The Vertebrate MitochondrialCode...

## fasta to gbk
/00_tools/fa2gb.py ${close_sp_mit_fa} ${close_sp_mit_fa}.gb

/usr/bin/singularity exec --bind $PWD:$PWD mitohifi.sif mitohifi.py -r ${ccs_reads} -f ${close_sp_mit_fa} -g ${close_sp_mit_fa}.gb -t ${cpu} -a ${sp} --circular-size 2000 -o ${GENETIC_CODE} --mitos

<<!!
usage: MitoHiFi [-h] (-r <reads>.fasta | -c <contigs>.fasta) -f
                <relatedMito>.fasta -g <relatedMito>.gbk -t <THREADS> [-d]
                [-a {animal,plant,fungi}] [-p <PERC>] [-m <BLOOM FILTER>]
                [--max-read-len MAX_READ_LEN] [--mitos]
                [--circular-size CIRCULAR_SIZE]
                [--circular-offset CIRCULAR_OFFSET] [-winSize WINSIZE]
                [-covMap COVMAP] [-v] [-o <GENETIC CODE>]

required arguments:
  -r <reads>.fasta      -r: Pacbio Hifi Reads from your species
  -c <contigs>.fasta    -c: Assembled fasta contigs/scaffolds to be searched
                        to find mitogenome
  -f <relatedMito>.fasta
                        -f: Close-related Mitogenome is fasta format
  -g <relatedMito>.gbk  -k: Close-related species Mitogenome in genebank
                        format
  -t <THREADS>          -t: Number of threads for (i) hifiasm and (ii) the
                        blast search

optional arguments:
  -d                    -d: debug mode to output additional info on log
  -a {animal,plant,fungi}
                        -a: Choose between animal (default) or plant
  -p <PERC>             -p: Percentage of query in the blast match with close-
                        related mito
  -m <BLOOM FILTER>     -m: Number of bits for HiFiasm bloom filter [it maps
                        to -f in HiFiasm] (default = 0)
  --max-read-len MAX_READ_LEN
                        Maximum lenght of read relative to related mito
                        (default = 1.0x related mito length)
  --mitos               Use MITOS2 for annotation (opposed to default
                        MitoFinder
  --circular-size CIRCULAR_SIZE
                        Size to consider when checking for circularization
  --circular-offset CIRCULAR_OFFSET
                        Offset from start and finish to consider when looking
                        for circularization
  -winSize WINSIZE      Size of windows to calculate coverage over the
                        final_mitogenom
  -covMap COVMAP        Minimum mapping quality to filter reads when building
                        final coverage plot
  -v, --version         show program's version number and exit
  -o <GENETIC CODE>     -o: Organism genetic code following NCBI table (for
                        mitogenome annotation): 1. The Standard Code 2. The
                        Vertebrate MitochondrialCode 3. The Yeast
                        Mitochondrial Code 4. The Mold,Protozoan, and
                        Coelenterate Mitochondrial Code and the
                        Mycoplasma/Spiroplasma Code 5. The Invertebrate
                        Mitochondrial Code 6. The Ciliate, Dasycladacean and
                        Hexamita Nuclear Code 9. The Echinoderm and Flatworm
                        Mitochondrial Code 10. The Euplotid Nuclear Code 11.
                        The Bacterial, Archaeal and Plant Plastid Code 12. The
                        Alternative Yeast Nuclear Code 13. The Ascidian
                        Mitochondrial Code 14. The Alternative Flatworm
                        Mitochondrial Code 16. Chlorophycean Mitochondrial
                        Code 21. Trematode Mitochondrial Code 22. Scenedesmus
                        obliquus Mitochondrial Code 23. Thraustochytrium
                        Mitochondrial Code 24. Pterobranchia Mitochondrial
                        Code 25. Candidate Division SR1 and Gracilibacteria
                        Code
!!
