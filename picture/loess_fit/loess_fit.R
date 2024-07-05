# 加载必要的包
library(ggplot2)

args <- commandArgs(T)

# 定义读取数据文件的路径
input_file_path <- args[1]
output_file_path <- args[2]

# 读取数据文件
data <- read.table(input_file_path, header = FALSE, col.names = c("Dist", "Mean_r"))

# 使用 LOESS 方法进行局部加权多项式回归
loess_fit <- loess(Mean_r ~ Dist, data = data, span = 0.75)

# 创建预测值
data$Loess_Fit <- predict(loess_fit, newdata = data$Dist)

# 将 LOESS 拟合结果保存到 CSV 文件
write.csv(data, output_file_path, row.names = FALSE)

# 绘制图表
plot <- ggplot(data, aes(x = Dist, y = Mean_r)) +
  geom_point(size = 1) +                           # 原始数据点
  geom_line(aes(y = Loess_Fit), color = 'blue', linewidth = 1) +  # LOESS 平滑曲线
  labs(title = "LD Decay with LOESS",
       x = "Distance",
       y = expression(Mean~r)) +
  theme_minimal()

# 保存图表为 PNG 文件
ggsave(args[3], plot = plot, width = 10, height = 6)
