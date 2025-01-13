import sys
import numpy as np
import pandas as pd

def remove_outliers_iqr(data_series, m=1):
    q1 = data_series.quantile(0.25)
    q3 = data_series.quantile(0.75)
    iqr = q3 - q1
    lower_bound = q1 - m * iqr
    upper_bound = q3 + m * iqr
    return data_series[(data_series >= lower_bound) & (data_series <= upper_bound)]

def main(input_file, output_file):
    # 读取数据文件
    data = pd.read_csv(input_file, sep='\t', header=None)

    # 假设第一列是样本名，第二列是数值
    sample_names = data[0]
    values = data[1]

    # 剔除离群值
    cleaned_values = remove_outliers_iqr(values)

    # 创建一个新的DataFrame来保存结果
    cleaned_data = pd.DataFrame({'Sample': sample_names, 'Value': cleaned_values})

    # 将结果保存到新的文件
    cleaned_data.to_csv(output_file, sep='\t', index=False)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_file> <output_file>")
        sys.exit(1)

    input_file_path = sys.argv[1]
    output_file_path = sys.argv[2]

    main(input_file_path, output_file_path)
