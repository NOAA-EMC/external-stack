#!/bin/bash

set -ex

name="fftw"
version=$1

software=$name-$version

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')
mpi=$(echo $JEDI_MPI | sed 's/\//-/g')

set +x
source $MODULESHOME/init/bash
module load jedi-$JEDI_COMPILER
[[ -z $mpi ]] || module load jedi-$JEDI_MPI 
module list
set -x

if [[ ! -z $mpi ]]; then
  export FC=$MPI_FC
  export CC=$MPI_CC
  export CXX=$MPI_CXX
else
  export FC=$SERIAL_FC
  export CC=$SERIAL_CC
  export CXX=$SERIAL_CXX
fi

export F77=$FC
export FFLAGS="-fPIC"
export CFLAGS="-fPIC"

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

url="http://fftw.org/${software}.tar.gz"
[[ -d $software ]] || ( $WGET $url; tar -xf $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
if [[ -d $prefix ]]; then
  [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                             || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
fi

[[ -z $mpi ]] || ( export MPICC=$MPI_CC; extra_conf="--enable-mpi" )

../configure --prefix=$prefix --enable-openmp --enable-threads $extra_conf

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
