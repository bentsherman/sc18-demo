#!/bin/bash

# parse command-line arguments
if [[ $# != 1 ]]; then
	echo "usage: $0 <num-processes>"
	exit -1
fi

INFILE="input/hallmark_experiments_20.txt"
NP=$1

# prepare input
./split.sh $INFILE $NP

# run gene-oracle
module purge
module add anaconda3/5.1.0

source activate gene-oracle

for (( i = 0; i < $NP; i++ )); do
	./gene-oracle-worker.sh $i &
done
time wait

source deactivate

# cleanup
rm $(dirname $INFILE)/$(basename $INFILE .txt).*.txt
