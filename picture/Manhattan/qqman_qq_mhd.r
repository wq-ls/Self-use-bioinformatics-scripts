library(qqman)
args <- commandArgs(T)

results_log <- read.table(args[1], header=T)
p_value=results_log$P
z = qnorm(p_value/ 2)
lambda = round(median(z^2, na.rm = TRUE) / 0.454, 3)
lambda

jpeg(paste(args[2], ".jpeg", sep = "", collapse = ""))

qq(results_log$P, main = "Q-Q plot of GWAS p-values : log", xlim = c(0, 7),  ylim = c(0, 12), pch = 18, col = "blue4", cex = 0.5, las = 1)
manhattan(results_log,chr="CHR",bp="BP",p="P",snp="SNP", main = "Manhattan plot")

dev.off()
