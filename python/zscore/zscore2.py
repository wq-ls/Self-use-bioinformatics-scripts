# Usage: python zscore_large_file_parallel.py input_file output_file num_threads chunksize

import sys
import pandas as pd
import numpy as np
from concurrent.futures import ThreadPoolExecutor

def calculate_zscore(values, mean, std):
    """计算 Z-score"""
    return (values - mean) / std

def process_chunk(chunk, mean, std, last_column_name):
    """处理单个分块，计算 Z-score 并新增列"""
    chunk[f"{last_column_name}_zscore"] = calculate_zscore(chunk[last_column_name].to_numpy(dtype=float), mean, std)
    return chunk

def calculate_zscore_in_chunks_parallel(input_file, output_file, num_threads, chunksize):
    # 首先计算最后一列的全局均值和标准差（两次遍历文件）
    total_sum, total_sq_sum, total_count = 0, 0, 0
    last_column_name = None

    # 第一次遍历：计算全局均值和标准差
    for chunk in pd.read_csv(input_file, sep='\t', chunksize=chunksize):
        if last_column_name is None:
            last_column_name = chunk.columns[-1]
        last_column_values = chunk[last_column_name].to_numpy(dtype=float)  # 提取最后一列为 NumPy 数组
        total_sum += np.sum(last_column_values)
        total_sq_sum += np.sum(last_column_values**2)
        total_count += len(last_column_values)

    # 计算全局均值和标准差
    mean = total_sum / total_count
    std = np.sqrt(total_sq_sum / total_count - mean**2)

    # 第二次遍历：多线程并行计算 Z-score，并写入文件
    with open(output_file, 'w') as f_out:
        header_written = False  # 用于控制是否写入表头
        with ThreadPoolExecutor(max_workers=num_threads) as executor:
            for chunk in pd.read_csv(input_file, sep='\t', chunksize=chunksize):
                # 提交任务到线程池，处理单个分块
                future = executor.submit(process_chunk, chunk, mean, std, last_column_name)
                processed_chunk = future.result()

                # 写入文件，第一次写入表头，后续不再写入
                processed_chunk.to_csv(f_out, sep='\t', index=False, header=not header_written)
                header_written = True  # 写入一次表头后设置为 True

if __name__ == "__main__":
    # 获取命令行参数
    if len(sys.argv) < 5:
        print("Usage: python zscore_large_file_parallel.py <input_file> <output_file> <num_threads> <chunksize>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]
    num_threads = int(sys.argv[3])  # 自定义线程数
    chunksize = int(sys.argv[4])  # 自定义分块大小

    # 调用主函数
    calculate_zscore_in_chunks_parallel(input_file, output_file, num_threads, chunksize)
