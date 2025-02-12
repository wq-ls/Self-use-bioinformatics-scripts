library(ggplot2)
library(grid)
 
#读取文件
depth_gc <- read.delim('Depth_GC.txt')
#seq start   end Depth   GC
#chr1    0   2000    4.6190000   0.491000
#chr1    2000    4000    15.8795004  0.502000
#chr1    4000    6000    3.4749999   0.501500
#chr1    6000    8000    3.5050001   0.501500
 
#GC 含量中位数（百分比）
depth_gc$GC <- 100 * depth_gc$GC
GC_median <-  round(median(depth_gc$GC), 2)
 
#测序深度中位数
depth_median <- round(median(depth_gc$Depth), 2)
 
#为了避免二代测序的 duplication 所致的深度极高值，将高于测序深度中位数 3 倍的数值去除
depth_gc <- subset(depth_gc, Depth <= 3 * depth_median)
 
#depth 深度、GC 含量散点密度图
depth_GC <- ggplot(depth_gc, aes(GC, Depth)) +
    geom_point(color = 'gray', alpha = 0.6, pch = 19, size = 0.5) +
#    geom_vline(xintercept = GC_median, color = 'red', lty = 2, lwd = 0.5) + 
#    geom_hline(yintercept = depth_median, color = 'red', lty = 2, lwd = 0.5) +
    stat_density_2d(aes(fill = ..density.., alpha = ..density..), geom = 'tile', contour = FALSE, n = 500) +
    scale_fill_gradientn(colors = c('transparent', 'gray', 'blue', 'red')) +
    theme(panel.grid.major = element_line(color = 'gray', linetype = 2, size = 0.25), panel.background = element_rect(color = 'black', fill = 'transparent')) +
    labs(x = paste('GC % (Median :', GC_median, '%)'), y = paste('Depth (Median :', depth_median, 'X)')) +
    theme(axis.text = element_text(size = 8), axis.title = element_text(size = 12)) +
    theme(legend.position = 'none')
 
#depth 深度频数直方图
depth_hist <- ggplot(depth_gc, aes(Depth)) +
    geom_histogram(binwidth = (max(depth_gc$Depth) - min(depth_gc$Depth))/100, fill = 'gray', color = 'gray40', size = 0.1) +
    geom_rug(color = 'gray', alpha = 0.6) +
    theme(panel.grid.major = element_line(color = 'gray', linetype = 2, size = 0.25), panel.background = element_rect(color = 'black', fill = 'transparent')) +
    theme(axis.line = element_line(color = 'black', size = 0.3), axis.text = element_text(size = 8), axis.title = element_text(size = 12)) +
    labs(x = '', y = 'Numbers') +
    coord_flip()
#    geom_vline(xintercept = depth_median, color = 'red', lty = 2, lwd = 0.5)
 
#GC 含量频数直方图
GC_hist <- ggplot(depth_gc, aes(GC)) +
    geom_histogram(binwidth = (max(depth_gc$GC) - min(depth_gc$GC))/100, fill = 'gray', color = 'gray40', size = 0.1) +
    geom_rug(color = 'gray', alpha = 0.6) +
    theme(panel.grid.major = element_line(color = 'gray', linetype = 2, size = 0.25), panel.background = element_rect(color = 'black', fill = 'transparent')) +
    theme(axis.line = element_line(color = 'black', size = 0.3), axis.text = element_text(size = 10), axis.title = element_text(size = 12)) +
    labs(x = '', y = 'Numbers')
#    geom_vline(xintercept = GC_median, color = 'red', lty = 2, lwd = 0.5)
 
#组合图片并输出
#pdf('GC_Depth.pdf', width = 8, height = 8)
#    grid.newpage()
#    pushViewport(viewport(layout = grid.layout(3, 3)))
#    print(depth_GC, vp = viewport(layout.pos.row = 2:3, layout.pos.col = 1:2))
#    print(GC_hist, vp = viewport(layout.pos.row = 1, layout.pos.col = 1:2))
#    print(depth_hist, vp = viewport(layout.pos.row = 2:3, layout.pos.col = 3))
#dev.off()
 
png('GC_Depth.png', width = 4000, height = 4000, res = 600, units = 'px')
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(3, 3)))
    print(depth_GC, vp = viewport(layout.pos.row = 2:3, layout.pos.col = 1:2))
    print(GC_hist, vp = viewport(layout.pos.row = 1, layout.pos.col = 1:2))
    print(depth_hist, vp = viewport(layout.pos.row = 2:3, layout.pos.col = 3))
dev.off()
