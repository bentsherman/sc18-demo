#!/bin/bash

# parse command-line arguments
if [[ $# != 1 ]]; then
	echo "usage: $0 <rank>"
	exit -1
fi

export CUDA_VISIBLE_DEVICES=$1

# run gene-oracle
cd gene-oracle

INDEX=$(printf %02d $1)
INPUT_DIR="../input"
OUTPUT_DIR="../output"

DATASET="$INPUT_DIR/gtex_gct_data_float_v7.npy"
GENE_LIST="$INPUT_DIR/gtex_gene_list_v7.npy"
SAMPLE_JSON="$INPUT_DIR/gtex_tissue_count_v7.json"
SUBSET_LIST="$INPUT_DIR/hallmark_experiments_20.$INDEX.txt"
CONFIG="models/net_config.json"
KFOLD=3
OUT_FILE="$OUTPUT_DIR/results.$INDEX.hallmark.log"

python scripts/classify.py \
	--dataset     $DATASET \
	--gene_list   $GENE_LIST \
	--sample_json $SAMPLE_JSON \
	--subset_list $SUBSET_LIST \
	--config      $CONFIG \
	--k_fold      $KFOLD \
	--out_file    $OUT_FILE
