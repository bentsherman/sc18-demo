# SC18 Demo

For the SC18 demo we will showcase two bioinformatics workflows that can be run on a GPU cluster. The key point is that bioinformatics workflows lend themselves extremely well to parallelization because there is very little communication -- there are just a ton of independent data items that need to be processed (as opposed to an iterative algorithm such as a simulation).

## Accessing Palmetto

Before doing anything else you need the following:
- Access to the Palmetto cluster (either via SSH or JupyterHub)
- Access to a phase18a node (through the `smith_mri` queue).
- The files for this demo unzipped in your home directory on Palmetto

You can access the appropriate compute node with this command:
```bash
qsub -I -q smith_mri -l select=1:ncpus=40:mpiprocs=5:ngpus=4:gpu_model=v100nv:mem=80gb,walltime=72:00:00
```

On JupyterHub you should use the following options:
- __Number of resource chunks:__ 2
- __CPU cores per chunk:__ 16
- __Amount of memory per chunk:__ 30gb
- __Number of GPUs per chunk:__ 2
- __Walltime:__ 72 hours
- __Queue:__ smith_mri

## Installation

This README assumes that the files for this demo are in a directory called `sc18-demo`.

Scripts are provided to install gene-oracle and KINC automatically. Remember to login to a compute node before running these scripts:
```bash
cd sc18-demo

./install-gene-oracle.sh
./install-ace.sh
./install-kinc.sh
```

## Usage

### Chunk and Merge: Gene Oracle

Gene Oracle is a tool for identifying "biomarkers", or genes/gene sets that are indicators of biological processes (such as tissue development or tumor development). For this demo we will showcase the first phase of Gene Oracle, in which we take a list of curated gene sets and score each set by how well a neural network can classify a dataset using only the genes in that set. We will use the GTEx dataset, which contains approximately 10,000 samples and 60,000 genes, and the first 20 Hallmark gene sets, each of which contains 30-200 genes.

Since Tensorflow is used in the backend, we can train and evaluate neural networks with GPU acceleration out-of-the-box, but we can also process the gene sets in parallel if we have multiple GPUs. To do that, we split the input file into "chunks", pass each input chunk to a separate process with it's own GPU, and merge the output files at the end.

We have set up a small test case so that you can show a simple example of running Gene Oracle with 1 GPU and multiple GPUs:
```bash
# run gene-oracle with 1 GPU (should take about 5 minutes)
./gene-oracle.sh 1

# run gene-oracle with 4 GPUs (should take about 1.5 minutes)
./gene-oracle.sh 4
```

### Master and Worker: KINC

KINC is a tool that creates a gene coexpression network (GCN) from a gene expression matrix (GEM) by computing a pairwise similarity matrix using the Pearson or Spearman correlation. KINC can also perform pairwise clustering in order to identify multiple modes of correlation, which is typically the case when there are a wide variety of samples in the input data. However, this clustering step incurs a tremendous amount of computations which becomes intractable for large datasets, unless you have an extremely large allocation on OSG or XSEDE, or a GPU cluster. For this demo we will showcase KINC with both clustering and correlation, but on a small dataset called Yeast-1000, which contains 1000 genes and approximately 200 samples.

KINC can run on a single CPU, a single GPU, multiple CPUs, or multiple GPUs. When using multiple processes, the first process is the "master" which distributes work items to the other "worker" processes. The master also gathers the results from the workers and saves everything to the output files. This way, we don't have to do any chunking/merging of the input/output files.

Here is a small test case that you can run:
```bash
# run KINC with 1 GPU (should take about 2.5 minutes)
./kinc-similarity.sh 1

# run KINC with 1 master / 1 GPU (should take about 2.5 minutes)
./kinc-similarity.sh 2

# run KINC with 1 master / 4 GPUs (should take about 40 seconds)
./kinc-similarity.sh 5
```

### Monitoring GPU Usage

If you want, you can use `nvidia-smi` to show how the GPUs are being used. You'll need to open another terminal (either via SSH or JupyterHub):
```bash
watch nvidia-smi
```

You can SSH into an existing compute node from the login node. For example, if you have a job running on `node0006`:
```bash
ssh node0006
```
