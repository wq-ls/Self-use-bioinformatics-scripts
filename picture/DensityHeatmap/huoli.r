args <- commandArgs(T)

library(LSD)
pdf(paste(args[1], ".pdf", sep = "", collapse = ""))
rawcount <- read.table(args[1], header = T, sep="\t")
heatscatter(rawcount[,1],rawcount[,2])
