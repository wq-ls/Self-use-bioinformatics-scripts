
library(optparse)
option_list <- list(
    make_option(c("-v", "--info"), type = "character", default=F, metavar="info",
                help="The firt version to find Reciprocal best hit using diamond.\n\t\t!!! Example: diamond_rbh.R -a a.pep -b b.pep -c 10 -e 1E-3 -m 1 -M ultra-sensitive !!!"),
    make_option(c("-a", "--speA"), type = "character", default=NULL, metavar="pepA.fa",
                help="pep.fasta of Species A"),
    make_option(c("-b", "--speB"), type="character", default=NULL, metavar="pepB.fa",
                help="pep.fasta of Species B"),
    make_option(c("-o", "--output"), type="character", default='output.csv', metavar="output",
                help="RBH result"),
    make_option(c("-c", "--cpu"), type="integer", default=1, metavar="Number",
                help="cpu number. defult: 1"),
    make_option(c("-e", "--evalue"), default=1E-3, metavar="Number",
                help="Expectation value. defult: 1E-3"),
    make_option(c("-m", "--max"), type="integer", default=1, metavar="Number",
                help="maximum number of aligned sequences that shall be retained. defult: 1"),
    make_option(c("-M", "--model"), default='ultra-sensitive', metavar="aligned model",
                help="sensitivity_mode: defult: ultra-sensitive
                      fast : fastest alignment mode, but least sensitive (default). Designed for finding hits of >70.
                      mid-sensitive : fast alignments between the fast mode and the sensitive mode in sensitivity.
                      sensitive : fast alignments, but full sensitivity for hits >40.
                      more-sensitive : more sensitive than the sensitive mode.
                      very-sensitive : sensitive alignment mode.
                      ultra-sensitive : most sensitive alignment mode (sensitivity as high as BLASTP).")
)

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$speA)){
  print_help(opt_parser)}

speA = opt$speA
speB = opt$speB
cpu = opt$cpu
evalue = opt$evalue
max = opt$max
model = opt$model
output = opt$output

library("homologr")

rec_best_hits <- diamond_reciprocal_best_hits(
  query = speA,
  subject = speB,
  is_subject_db = FALSE,
  format = "fasta",
  sensitivity_mode = model,
  out_format = "csv",
  evalue = evalue,
  max_target_seqs = max,
  cores = cpu,
  hard_mask = TRUE,
  diamond_exec_path = "",
  add_makedb_options = NULL,
  add_diamond_options = NULL,
  output_path = getwd()
)

write.csv(rec_best_hits,file=output,quote=F,row.names = F)

