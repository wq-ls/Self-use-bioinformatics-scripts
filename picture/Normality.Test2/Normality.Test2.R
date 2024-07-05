library("ggpubr")
args <- commandArgs (T)

indata <- read.table(args[1], header=T, sep="\t", quote="")

# 定义函数
  Normality_test <- function(input_file, type) {

  indata <- read.table(input_file, header=T, sep="\t", quote="")

  #pdf(output_file, width = 7, height = 6)

  #ggdensity(indata, x= type,  main = "Density")

  #ggqqplot(indata, x= type)   ### color = group , palette = c("#00AFBB", "#E7B800"))

  expression_to_eval <- paste0("indata$", type)
  shapiro.test(eval(parse(text = expression_to_eval)))

}

Normality_test(input_file = args[1], type = args[2])
