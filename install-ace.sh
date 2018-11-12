#!/bin/bash

MODULEDIR="$HOME/privatemodules"
SOFTWAREDIR="$HOME/software"

MODULE_NAME="ACE"
MODULE_VERSION="develop"
MODULE_PATH="$SOFTWAREDIR/$MODULE_NAME/$MODULE_VERSION"

module purge
module add cuda-toolkit/9.2
module add gcc/5.4.0
module add git
module add openmpi/1.10.7
module add Qt/5.9.2

# build ACE from source
BUILDDIR="$HOME/ACE"

rm -rf $MODULE_PATH

if [ ! -d $BUILDDIR ]; then
	git clone https://github.com/SystemsGenetics/ACE.git $BUILDDIR

	cd $BUILDDIR
	git checkout develop
fi

cd "$BUILDDIR/build"

qmake ../src/ACE.pro PREFIX=$MODULE_PATH
make clean
make -j $(cat $PBS_NODEFILE | wc -l)
make qmake_all
make -j $(cat $PBS_NODEFILE | wc -l) install

# create modulefile
mkdir -p $MODULEDIR/$MODULE_NAME

cat > "$MODULEDIR/$MODULE_NAME/$MODULE_VERSION" <<EOF
#%Module1.0
##
## $MODULE_NAME/$MODULE_VERSION  modulefile
##
module-whatis "Set up environment for $MODULE_NAME"
module add cuda-toolkit/9.0.176
module add gcc/5.4.0
module add openmpi/1.10.7
module add Qt/5.9.2

# for Tcl script use only
set version "3.2.6"

# Make sure no other hpc modulefiles are loaded before loading this module
eval set [ array get env MODULESHOME ]

prepend-path PATH                $MODULE_PATH/bin
prepend-path CPLUS_INCLUDE_PATH  $MODULE_PATH/include
prepend-path LD_LIBRARY_PATH     $MODULE_PATH/lib
prepend-path LIBRARY_PATH        $MODULE_PATH/lib
EOF
