import sys
from numpy.random import permutation
from pandas import read_csv

def shuffle_file(csv_file):
    shuffled = csv_file.iloc[permutation(csv_file.index)].reset_index(drop=True)
    return shuffled

def safe_train(file_in, file_out, shuffle, train_ratio):
    df = read_csv(file_in, delimiter = ',')
    if shuffle:
        df = shuffle_file(df)
    filtred_csv = df.head(train_ratio)
    filtred_csv.to_csv(file_out, header = False)

def safe_train_and_val(file_in, train_out, val_out, shuffle, train_ratio):
    df = read_csv(file_in, delimiter = ',')
    number_of_rows = len(df)
    count = round(int(train_ratio) * number_of_rows / 100)
    if shuffle:
        df = shuffle_file(df)
    train_csv = df.head(count)
    val_csv = df.tail(number_of_rows - count)
    train_csv.to_csv(train_out, header = False)
    val_csv.to_csv(val_out, header = False)


n = len(sys.argv)
if n == 5:
    input_file = sys.argv[1]
    shuffle = sys.argv[2]
    train_ratio = sys.argv[3]
    path_to_train = sys.argv[4]
    safe_train(input_file, bool(shuffle), path_to_train)

elif n == 6:
    input_file = sys.argv[1]
    shuffle = sys.argv[2]
    train_ratio = sys.argv[3]
    path_to_train = sys.argv[4]
    path_to_val = sys.argv[5]

    safe_train_and_val(input_file, path_to_train, path_to_val, bool(shuffle), train_ratio)



