library(clusterProfiler)
library(org.Trubripes.eg.db)
library(ggplot2)
library(enrichplot)
library(stringr)
args <- commandArgs(T)
dir.create(args[1])
data <- read.table(args[2],header=F)
setwd(args[1])
genes <- as.character(data$V1)
ego <- enrichGO(gene          = genes, # list of entrez gene id
                OrgDb         = org.Trubripes.eg.db, # 背景使用分析物种的org包
                keyType       = 'GID',
                ont           = "ALL", #  "BP", "MF", "CC", "ALL"。GO三个子类。
                pAdjustMethod = "BH", # 多重假设检验，"holm", "hochberg", "hommel", "bonferroni", "BY", "fdr"
                pvalueCutoff  = 0.05, # 富集分析的pvalue，默认是pvalueCutoff = 0.05，更严格可选择0.01
                qvalueCutoff  = 0.2) # 富集分析显著性的qvalue，默认是qvalueCutoff = 0.2，更严格可选择0.05
go.res <- data.frame(ego)

goBP <- subset(go.res,subset = (ONTOLOGY == "BP"))[1:15,]
goCC <- subset(go.res,subset = (ONTOLOGY == "CC"))[1:10,]
goMF <- subset(go.res,subset = (ONTOLOGY == "MF"))[1:10,]
go.df <- rbind(goBP,goCC,goMF)

# 使画出的GO term的顺序与输入一致
go.df$Description <- factor(go.df$Description,levels = rev(go.df$Description))
go_bar <- ggplot(data = go.df, aes(x = Description, y = -log10(pvalue),fill = ONTOLOGY)) +
                 geom_bar(stat = "identity",width = 0.9) + coord_flip() + theme_bw() +
                 scale_x_discrete(labels = function(x) str_wrap(x,width = 50)) +
                 labs(x = "GO terms",y = "-log10(pvalue)",title = "Barplot of Enriched GO Terms") +
                 theme(axis.title = element_text(size = 13),axis.text = element_text(size = 11),plot.title = element_text(size = 14,hjust = 0.5,face = "bold"),legend.title = element_text(size = 13),legend.text = element_text(size = 11),plot.margin = unit(c(0.5,0.5,0.5,0.5),"cm"))

go_bar2 <- ggplot(data = go.df, aes(x = Description, y = Count,fill = ONTOLOGY)) +
                 geom_bar(stat = "identity",width = 0.9)+
                 coord_flip()+theme_bw()+ # 横纵坐标反转及去除背景色
                 scale_x_discrete(labels = function(x) str_wrap(x,width = 50))+ # 设置term名称过长时换行
                 labs(x = "GO terms",y = "Gene number",title = "Barplot of Enriched GO Terms")+ # 设置坐标轴标题及标题
                 theme(axis.title = element_text(size = 13), # 坐标轴标题大小
                 axis.text = element_text(size = 11), # 坐标轴标签大小
                 plot.title = element_text(size = 14,hjust = 0.5,face = "bold"), # 标题设置
                 legend.title = element_text(size = 13), # 图例标题大小
                 legend.text = element_text(size = 11), # 图例标签大小
                 plot.margin = unit(c(0.5,0.5,0.5,0.5),"cm")) # 图边距

pdf("GO_Barplot.pdf",width = 10,height = 10)
go_bar
go_bar2
dev.off()
write.table(go.df,"allGO_gene.xls",sep="\t",quote=F)

pdf("GO_treeplot.pdf",width=15,height=10)
edox2 <- pairwise_termsim(ego) ###top30BP
treeplot(edox2)
dev.off()
write.table(as.data.frame(edox2)[1:30,],"top30BP_gene.xls",sep="\t",quote=F)

kegg_anno <- read.table(args[3], sep="\t", header=T)
kegg2gene <- kegg_anno[, c(2, 1)]
kegg2name <- kegg_anno[, c(2, 3)]
kegg <- enricher(genes, TERM2GENE = kegg2gene, TERM2NAME = kegg2name, pAdjustMethod = "BH", pvalueCutoff  = 0.05, qvalueCutoff  = 0.2)

pdf("KEGG_Barplot.pdf")
barplot(kegg, showCategory=20, title="Enrichment_KEGG")
dev.off()
write.table(kegg[1:30,],"top30KEGG_gene.xls",sep="\t",quote=F)
pdf("KEGG_treeplot.pdf",width=15,height=10)
edox2 <- pairwise_termsim(kegg) ###top30BP
treeplot(edox2)
dev.off()
