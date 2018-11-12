#!/bin/bash

# create Anaconda environment
module purge
module add anaconda3/5.1.0
module add git

conda create -n gene-oracle -y \
	python=2.7 \
	matplotlib \
	numpy \
	scikit-learn \
	tensorflow-gpu=1.7.0

# install gene-oracle
git clone https://github.com/feltus/gene-oracle.git

# copy input data from shared storage
mkdir -p input

cp /zfs/feltus/ctargon/gene_lists/gtex_gene_list_v7.npy input
cp /zfs/feltus/ctargon/gems/gtex_gct_data_float_v7.npy input
cp /zfs/feltus/ctargon/class_counts/gtex_tissue_count_v7.json input
