## usage: python zscore.py input output

import sys
import pandas
from pandas import read_excel
from sklearn import preprocessing

input_file = sys.argv[1]
output_file = sys.argv[2]

dataset = pandas.read_csv(input_file, index_col=0)
# dataframe to array
values = dataset.values
# define date type
values = values.astype(float)
# stat zscore
data = preprocessing.scale(values)
# array to datafarme
df = pandas.DataFrame(data)
# name columns
df.columns = dataset.columns
# name rows
df.index = dataset.index
# output file ps: three decimal places
df.to_csv(output_file, float_format='%.3f', sep='\t')
