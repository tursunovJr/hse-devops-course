#!/bin/bash
while [ -n "$1" ]
do
case "$1" in
--input) input_param="$2" 
shift ;;
--shuffle) shuffle_param="$2" 
shift ;;
--train_ratio) train_param="$2"
shift ;;
--save_train) save_train_param="$2"
shift ;;
--save_val) save_val_param="$2"
shift ;;
*) echo "$1 is not an option" ;;
esac
shift
done

number_of_rows=$(wc -l < $input_param)
number_of_rows=$(echo $number_of_rows)
train_ratio=$(($number_of_rows * $train_param / 100))
val_ratio=$((train_ratio + 1))

if [[ "$shuffle_param" == 1 ]]; then
    cat $input_param | gshuf > ./test.csv
    cat ./test.csv | sed -n "2,$train_ratio p" >> $save_train_param
    cat ./test.csv | sed -n "$val_ratio,$number_of_rows p" >> $save_val_param
else
    cat $input_param | sed -n "2,$train_ratio p" >> $save_train_param
    cat $input_param | sed -n "$val_ratio,$number_of_rows p" >> $save_val_param
fi