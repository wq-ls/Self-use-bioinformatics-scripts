library(ggplot2)
args <- commandArgs (T)

# 定义函数
plot_line_chart <- function(input_file, output_file, pos, data_column) {
  # 读取数据
  data <- read.table(input_file, header = TRUE)

  # 绘制折线图
  pdf(output_file, width = 15, height = 6)

  ggplot(data, aes_string(x = pos, y = data_column)) + geom_line() + theme_minimal()
}

# 调用函数并绘制折线图
plot_line_chart(input_file = args[1], output_file = args[2], pos = args[3], data_column = args[4])
