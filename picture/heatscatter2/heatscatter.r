library(xbox)
args <- commandArgs (T)

rawcount <- read.table(args[1], header = T, sep="\t")
pdf(paste(args[1], ".pdf", sep = "", collapse = ""))

heatpoint(rawcount[,1],rawcount[,2]) -> dat_result
str(dat_result)

head(dat_result$plot.data)
data.frame(dat_result$cor.result)
str(dat_result$lm.result)
xplot(dat_result)
