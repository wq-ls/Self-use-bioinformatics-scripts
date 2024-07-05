library(ggplot2)
library(readr)

args <- commandArgs (T)

file_path <- args[1]
x_column <- args[2]
y_column <- args[3]

# 读取数据，跳过标题行
data <- read_delim(file_path, col_names = TRUE)

# 检查列是否存在
if (!(x_column %in% colnames(data)) || !(y_column %in% colnames(data))) {
  stop("One or both of the specified columns do not exist in the data.")
}

# 选择您想要分析的两列
selected_data <- data[, c(x_column, y_column)]

# 检查选择的数据
#head(selected_data)

# 为渐变颜色定义颜色方案
color_scheme <- colorRampPalette(c("blue", "red"))(100)  # 生成100个渐变颜色

pdf(args[4], width = 15, height = 6)

# 使用ggplot2绘制箱线图和小提琴图的组合图
p <- ggplot(selected_data, aes_string(x = x_column, y = y_column)) +
#  geom_violin(trim = FALSE, fill = color_scheme[1]) + # 绘制小提琴图，使用渐变颜色
  stat_boxplot(geom = "errorbar",width=0.3) +
  geom_boxplot(width = 0.5, fill = color_scheme[2], outlier.fill = "grey", outlier.shape = 21) + # 绘制箱线图，使用渐变颜色
  labs(x = x_column, y = y_column) +
  theme_classic() + # 使用简洁主题
#  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) # 旋转X轴标签以便阅读
p
