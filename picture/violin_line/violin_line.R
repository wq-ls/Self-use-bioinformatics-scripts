suppressMessages(library(ggplot2))
suppressMessages(library(dplyr))
suppressMessages(library(stringr))
suppressMessages(library(ggpmisc))
suppressMessages(library(patchwork))

args <- commandArgs(T)
df <- read.table(args[1],head = T)
pdf(paste(args[2], ".pdf", sep = "", collapse = ""), width = 15, height = 6)

df %>%
  group_by(group) %>%
  summarise(median_value=median(value)) %>%
  bind_cols(x=c(1:4))-> df1

p1 <- ggplot(df, aes(group, value))+
  geom_violin(aes(fill = group),trim = FALSE)+
  geom_jitter(color = "black", fill = "white", shape = 21, width = 0.3, size = 2.5)+
  geom_smooth(aes(x = G, y = value),
              method = "lm", color = "#ee4f4f",
              level = 0.95,
              formula = y ~ poly(x, 1, raw = TRUE),
              linetype=1,alpha=0.2,linewidth = 1)+
  stat_poly_eq(formula = y ~ poly(x, 1, raw = TRUE),
               aes(x = G, y = value, label = paste(after_stat(eq.label),
                                                   after_stat(adj.rr.label),
                                                   sep = "~~~")),
               parse = TRUE,label.x = 0.05, label.y = 0.95,size=3.5,
               color = "black")+
  labs(x="Domestication levels", y = "Y-axis")+
  scale_fill_manual(values = c("#99CBEB","#4D97CD","#FDAE61","#D73027"))+
  theme_bw()+
  theme(legend.position = "none",
        panel.grid = element_blank(),
        axis.text.x = element_text(size = 10, angle = 45, vjust = 1, hjust = 1),
        axis.text.y = element_text(size = 10),
        axis.title = element_text(size=12, color = "black"))

p2 <- ggplot(df, aes(group, value))+
  geom_violin(aes(fill = group),trim = FALSE)+
  geom_jitter(color = "black", fill = "white", shape = 21, width = 0.3, size = 2.5)+
  geom_smooth(aes(x = G, y = value),
              method = "lm", color = "#ee4f4f",
              level = 0.95,
              formula = y ~ poly(x, 2, raw = TRUE),
              linetype=1,alpha=0.2,linewidth = 1)+
  stat_poly_eq(formula = y ~ poly(x, 2, raw = TRUE),
               aes(x = G, y = value, label = paste(after_stat(eq.label),
                                                   after_stat(adj.rr.label),
                                                   sep = "~~~")),
               parse = TRUE,label.x = 0.05, label.y = 0.95,size=3.5,
               color = "black")+
  labs(x="Domestication levels", y = "Y-axis")+
  scale_fill_manual(values = c("#99CBEB","#4D97CD","#FDAE61","#D73027"))+
  theme_bw()+
  theme(legend.position = "none",
        panel.grid = element_blank(),
        axis.text.x = element_text(size = 10, angle = 45, vjust = 1, hjust = 1),
        axis.text.y = element_text(size = 10),
        axis.title = element_text(size=12, color = "black"))

p3 <- ggplot(df, aes(group, value))+
  geom_violin(aes(fill = group),trim = FALSE)+
  geom_jitter(color = "black", fill = "white", shape = 21, width = 0.3, size = 2.5)+
  geom_smooth(aes(x = G, y = value),
              method = "lm", color = "#ee4f4f",
              level = 0.95,
              formula = y ~ poly(x, 3, raw = TRUE),
              linetype=1,alpha=0.2,linewidth = 1)+
  stat_poly_eq(formula = y ~ poly(x, 3, raw = TRUE),
               aes(x = G, y = value, label = paste(after_stat(eq.label),
                                                   after_stat(adj.rr.label),
                                                   sep = "~~~")),
               parse = TRUE,label.x = 0.05, label.y = 0.95,size=3.5,
               color = "black")+
  labs(x="Domestication levels", y = "Y-axis")+
  scale_fill_manual(values = c("#99CBEB","#4D97CD","#FDAE61","#D73027"))+
  theme_bw()+
  theme(legend.position = "none",
        panel.grid = element_blank(),
        axis.text.x = element_text(size = 10, angle = 45, vjust = 1, hjust = 1),
        axis.text.y = element_text(size = 10),
        axis.title = element_text(size=12, color = "black"))

p1 | p2 | p3
