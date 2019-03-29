#!/bin/sh

set -ex

name="hdf5"
version=$1

compiler=${COMPILER:-"gnu-7.3.0"}
mpi=${MPI:-""}

set +x
source $MODULESHOME/init/sh
module load $(echo $compiler | sed 's/-/\//g')
module load szip
module load $(echo $mpi | sed 's/-/\//g')
module list
set -x

if [[ ! -z $mpi ]]; then
    export FC=mpif90
    export CC=mpicc
    export CXX=mpicxx
fi

export F9X=$FC
export FFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export FCFLAGS="$FFLAGS"

cd ${PKGDIR:-"../pkg"}
[[ -d hdf5 ]] && cd hdf5 || (git clone  -b "hdf5-$version" https://bitbucket.hdfgroup.org/scm/hdffv/hdf5.git && cd hdf5 || (echo "git clone failed, ABORT!"; exit 1))

[[ -d build ]] && rm -rf build
mkdir -p build && cd build

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$mpi/$name/$version"

[[ -z $mpi ]] || extra_conf="--enable-parallel --enable-unsupported"

../configure --prefix=$prefix --enable-fortran --enable-cxx --enable-hl --enable-shared --with-szlib=$SZIP_ROOT $extra_conf

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

exit 0
