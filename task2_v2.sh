#!/bin/bash
while [ -n "$1" ]
do
case "$1" in
--input) input_param="$2" 
echo "$1 activated with param $input_param"
shift ;;
--shuffle) shuffle_param="$2" 
echo "$1 activated with param $shuffle_param" 
shift ;;
--train_ratio) train_param="$2"
echo "$1 activated with param $train_param"
shift ;;
--save_train) save_train_param="$2"
echo "$1 activated with param $save_train_param"
shift ;;
--save_val) save_val_param="$2"
echo "$1 activated with param $save_val_param"
shift ;;
*) echo "$1 is not an option" ;;
esac
shift
done

python3 main.py $input_param $shuffle_param $train_param $save_train_param $save_val_param