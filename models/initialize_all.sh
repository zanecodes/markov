#!/bin/bash

for dictionary in dictionaries/*.txt
do
  for n in 1 2 3 4 5
  do
    mkdir -p $n
    name_without_extension=${dictionary%.*}
    name_without_directory=${name_without_extension##*/}
    output_name="$n/$name_without_directory.bin"
    echo "Initializing $output_name..."
    ./initialize.rb $n $dictionary > $output_name
  done
done
