mkdir reference

reference=$PWD/reference
species=HCS
genome=HCS.fa

/gmap/bin/gmap_build -D $reference -d ${species}_reference $genome
