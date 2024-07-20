cwd=$PWD
indir=$cwd/00_data
cpu=10
prefix=Fish
### Options: blast, mmseqs, blast_gz, diamond
software=diamond

/usr/bin/singularity exec orthofinder.sif orthofinder -f $indir -t $cpu -a $cpu -S $software -n $prefix -p $cwd

## add species / remove species
# /usr/bin/singularity exec orthofinder.sif orthofinder -f $indir -t $cpu -a $cpu -S $software -n $prefix -p $cwd --fewer-files -X

### remove tmp file !!!!!!!!!!
#rm -rf $indir/Results_*/WorkingDirectory $indir/Results_*/Orthologues*/*_Trees $indir/Results_*/Orthologues*/WorkingDirectory

#mv $indir/Results_* $cwd/orthofinder_${prefix}
