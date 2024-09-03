source activate /home_micromamba/envs/sonicparanoid2/

cwd=$PWD
indir=$cwd/data
outdir=$cwd/sonicparanoid2_out
cpu=30
prefix=3spe
MIN_ARCH_MERGING_COV=0.75   ##  When merging graph- and arch-based orhtologs consider only new-orthologs with a protein coverage greater or equal than this value.
INFLATION=1.5
MIN_BITSCORE=40                 ##  Consider only alignments with bitscores above min-bitscore.
                                ##  Increasing this value can be a good idea when comparing very closely related species.
                                ##  Increasing this value will reduce the number of paralogs (and orthologs) generate.
                                ##  higher min-bitscore values reduce the execution time for all-vs-all. Default=40

sonicparanoid -i $indir -o $outdir -p $prefix -t $cpu -m sensitive -at -ka -ca -op -d --min-arch-merging-cov ${MIN_ARCH_MERGING_COV} -bs ${MIN_BITSCORE} --inflation ${INFLATION}

mv $outdir/runs/$prefix/* $outdir
mv $outdir/ortholog_groups $outdir/$prefix

### remove tmp file !!!!!!!!!!!!!!!!!!!!!
rm -rf $outdir/runs $outdir/orthologs_db $outdir/alignments $outdir/arch_orthology $outdir/merged_tables
