import sys
import pandas as pd

def remove_outliers_std(data_series, std_multiplier=3):
    """
    使用标准差方法剔除离群值。
    :param data_series: pandas.Series，包含数值数据。
    :param std_multiplier: 标准差的倍数，用于确定离群值的阈值，默认为3。
    :return: 剔除离群值后的Series。
    """
    mean = data_series.mean()
    std_dev = data_series.std()
    lower_bound = mean - std_multiplier * std_dev
    upper_bound = mean + std_multiplier * std_dev
    return data_series[(data_series >= lower_bound) & (data_series <= upper_bound)]

def main(input_file, output_file):
    # 读取数据文件
    data = pd.read_csv(input_file, sep='\t')

    # 假设第一列是样本名，第二列是数值
    sample_names = data.iloc[:, 0]
    values = data.iloc[:, 1]

    # 剔除离群值
    cleaned_values = remove_outliers_std(values)

    # 创建一个新的DataFrame来保存结果
    cleaned_data = pd.DataFrame({'Sample': sample_names, 'Values': cleaned_values})

    # 将结果保存到新的文件
    cleaned_data.to_csv(output_file, sep='\t', index=False)
    print(f"离群值已剔除，结果已保存到 {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_file> <output_file>")
        sys.exit(1)

    input_file_path = sys.argv[1]
    output_file_path = sys.argv[2]

    main(input_file_path, output_file_path)
