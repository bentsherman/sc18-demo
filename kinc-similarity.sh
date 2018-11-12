#!/bin/bash
#PBS -N kinc-similarity
#PBS -l select=2:ncpus=40:mpiprocs=5:ngpus=4:gpu_model=v100nv:mem=80gb,walltime=72:00:00
#PBS -j oe
#PBS -q smith_mri

# parse command-line arguments
if [[ $# != 1 ]]; then
	echo "usage: $0 <num-processes>"
	exit -1
fi

NP=$1
EMX_FILE="input/Yeast-1000.emx"
CCM_FILE="Yeast-1000.ccm"
CMX_FILE="Yeast-1000.cmx"
CLUSMETHOD="gmm"
CORRMETHOD="pearson"
WORK_BLOCK_SIZE=4096
GLOBAL_WORK_SIZE=1024
LOCAL_WORK_SIZE=32

# load modules
module purge
module add use.own
module add KINC/develop

# copy input data to each node
echo "Preparing input data..."

for NODE in $(uniq $PBS_NODEFILE); do
	ssh $NODE cp -r $PWD/input $TMPDIR/input
done

cd $TMPDIR

# set kinc settings
kinc settings set opencl 0:0
kinc settings set threads 1
kinc settings set logging off

# run kinc
echo "Running KINC with $NP processes..."

time mpirun -np $NP -quiet kinc run similarity \
	--input $EMX_FILE \
	--ccm $CCM_FILE \
	--cmx $CMX_FILE \
	--clusmethod $CLUSMETHOD \
	--corrmethod $CORRMETHOD \
	--bsize $WORK_BLOCK_SIZE \
	--gsize $GLOBAL_WORK_SIZE \
	--lsize $LOCAL_WORK_SIZE

# save output data
echo "Saving output data..."

mkdir -p $OLDPWD/output

cp $CCM_FILE $CMX_FILE $OLDPWD/output

cd $OLDPWD
