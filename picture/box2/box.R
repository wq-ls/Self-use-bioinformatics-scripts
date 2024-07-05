args <- commandArgs (T)
library(rlang)
library(ggstatsplot)

indata <- read.table(args[1], header=T, sep="\t", quote="")
pdf(args[2], width = 6, height = 6)

ggbetweenstats(
  data = indata,
  x = !!sym(args[3]),
  y = !!sym(args[4]),
  plot.type = "boxviolin",                    ### "boxviolin" "box" "violin"
  p.adjust.method  = "bonferroni",            ### "bonferroni" "fdr" "BH" "hochberg"
  pairwise.comparisons = TRUE,                ### "TRUE" "False"
  pairwise.display = "significant",           ### "significant" "non-significant" "everything"
  type = "nonparametric"                      ### "nonparametric" "parametric" "robust" "bayes"
)
