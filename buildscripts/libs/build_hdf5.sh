#!/bin/bash

set -ex

name="hdf5"
version=$1

# Hyphenated version used for install prefix
compiler=$(echo $COMPILER | sed 's/\//-/g')
mpi=$(echo $MPI | sed 's/\//-/g')

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load other/cmake
    module load core/jedi-$COMPILER
    module load jedi-$MPI
    module load szip zlib
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
    if [[ -d $prefix ]]; then
	[[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
            || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi

else
    prefix=${HDF5_ROOT:-"/usr/local"}
fi    

if [[ ! -z $mpi ]]; then
    export FC=$MPI_FC
    export CC=$MPI_CC
    export CXX=$MPI_CXX
else
    export FC=$SERIAL_FC
    export CC=$SERIAL_CC
    export CXX=$SERIAL_CXX
fi

export F9X=$FC
export FFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export FCFLAGS="$FFLAGS"

gitURL="https://bitbucket.hdfgroup.org/scm/hdffv/hdf5.git"

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$(echo $version | sed 's/\./_/g')
[[ -d $software ]] || ( git clone -b $software $gitURL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

[[ -z $mpi ]] || extra_conf="--enable-parallel --enable-unsupported"

../configure --prefix=$prefix --enable-fortran --enable-fortran2003 --enable-cxx --enable-hl --enable-shared --with-szlib=$SZIP_ROOT --with-zlib=$ZLIB_ROOT $extra_conf

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
[[ $USE_SUDO =~ [yYtT] ]] && sudo -- bash -c "export PATH=$PATH; make install" \
	                  || make install

# generate modulefile from template
#[[ -z $mpi ]] && modpath=compiler || modpath=mpi
#$MODULES && update_modules $modpath $name $version \
#	 || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log			   

exit 0
