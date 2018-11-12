#!/bin/bash

MODULEDIR="$HOME/privatemodules"
SOFTWAREDIR="$HOME/software"

MODULE_NAME="KINC"
MODULE_VERSION="develop"
MODULE_PATH="$SOFTWAREDIR/$MODULE_NAME/$MODULE_VERSION"

module purge
module add use.own
module add ACE/develop
module add git
module add gsl/2.3

# build KINC from source
BUILDDIR="$HOME/KINC"

rm -rf $MODULE_PATH

if [ ! -d $BUILDDIR ]; then
	git clone https://github.com/SystemsGenetics/KINC.git $BUILDDIR

	cd $BUILDDIR
	git checkout develop
fi

cd "$BUILDDIR/build"

qmake ../src/KINC.pro PREFIX=$MODULE_PATH
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
module add ACE/develop
module add gsl/2.3

# for Tcl script use only
set version "3.2.6"

# Make sure no other hpc modulefiles are loaded before loading this module
eval set [ array get env MODULESHOME ]

prepend-path PATH $MODULE_PATH/bin
EOF
