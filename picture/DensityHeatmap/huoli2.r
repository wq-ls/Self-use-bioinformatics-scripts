args <- commandArgs(T)

library(MASS)
library(LSD)
library(ggplot2)
library(ggthemes)

#pdf(paste(args[1], ".huoli2.pdf", sep = "", collapse = ""))
png(paste(args[1], ".huoli2.png", sep = "", collapse = ""))

DF <- read.table(args[1], header = F, sep="\t")

x <- DF$V1
y <- DF$V2
dens <- kde2d(x,y)

gr <- data.frame(with(dens, expand.grid(x,y)), as.vector(dens$z))
names(gr) <- c("xgr", "ygr", "zgr")

mod <- loess(zgr~xgr*ygr, data=gr)

DF$pointdens <- predict(mod, newdata=data.frame(xgr=x, ygr=y))

p <- ggplot(DF, aes(x=x,y=y, color=pointdens)) + theme_base() + scale_colour_gradientn(colours = colorpalette('heat', 5))
p <- p + geom_point()
p <- p + ggtitle('heatscatter')
p
