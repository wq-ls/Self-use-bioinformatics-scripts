#!/R-4.2/bin/Rscript

### https://cn.bio-protocol.org/bio101/e1010674
### https://cran.r-project.org/web/packages/ape/ape.pdf
### choose libPaths ###
.libPaths("/R-4.2/lib/R/library/")

args <- commandArgs (T)
library(ape)

tree <- read.tree(args[1])
pdf(paste(args[2], ".pdf", sep = "", collapse = ""), height = 15 )

par(mfrow = c(4, 2))
plot(tree, type = "p", main = "phylogram with branch lengths", sub = "A", use.edge.length = TRUE, tip.color = rainbow(5)) 
plot(tree, type = "p", main = "phylogram without branch lengths", sub = "B", use.edge.length = FALSE, edge.width = 1:27/2)
plot(tree, type = "c", main = "cladogram", sub = "C", edge.color = rainbow(27))
plot(tree, type = "f", main = "fan", sub = "D", font = 3)
plot(tree, type = "u", main = "unrooted", sub = "E")
plot(tree, type = "r", main = "radial", sub = "F")

plot(tree, type = "p", main = "phylogram with branch lengths", sub = "G", use.edge.length = TRUE, edge.width = 2)
nodelabels(bg = "lightgray", frame = "c")

plot(tree, type = "p", main = "phylogram with branch lengths", sub = "G", use.edge.length = TRUE, edge.width = 2)
edgelabels()
