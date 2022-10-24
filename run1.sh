#!/bin/bash
while [ -n "$1" ]
do
case "$1" in
--workers) workers="$2" 
echo "$1 activated with param $workers"
shift ;;
--column_links) column_links="$2" 
echo "$1 activated with param $column_links" 
shift ;;
--output_folder) output_folder="$2"
echo "$1 activated with param $output_folder"
shift ;;
*) echo "$1 is not an option" ;;
esac
shift
done


cat ./dataset_task1.csv | awk -v column="$column_links" -F ';' 'NR>1 {print $column}' | parallel -j $workers wget -P ./$output_folder -p -q {} 
