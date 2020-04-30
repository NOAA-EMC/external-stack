#!/bin/bash

set -ex

name="wgrib2"
version=$1

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')
mpi=$(echo $JEDI_MPI | sed 's/\//-/g')

# manage package dependencies here
if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    [[ -z $mpi ]] || module load jedi-$JEDI_MPI
    module try-load szip
    module load hdf5
    [[ -z $mpi ]] || module load pnetcdf
    module load netcdf
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi

else
    prefix=${WGRIB2_ROOT:-"/usr/local"}
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

export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export FCFLAGS="-fPIC"

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
tarball="${name}.tgz.v${version}"
url="https://www.ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/${tarball}"
[[ -d $software ]] || ( $WGET $url )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && rm -rf $software
tar -xzf ${tarball}; mv -f grib2 $software
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

# use this makefile.wgrib2, instead of the one in the tarball
cp ${JEDI_STACK_ROOT}/buildscripts/patches/makefile.wgrib2 .

# Variables internally used by makefile.wgrib2 (otherwise will be discovered!)
if [[ "$SERIAL_CC" == *"gcc"* ]]; then
  export COMP_SYS=gnu_linux
elif [[ "$SERIAL_CC" == *"icc"* ]]; then
  export COMP_SYS=intel_linux
elif [[ "$SERIAL_CC" == *"clang"* ]]; then
  export COMP_SYS=clang_linux
fi

# Create the utility (wgrib2) and library
make -f makefile.wgrib2
make -f makefile.wgrib2 lib

$SUDO mkdir -p $prefix/include
$SUDO mkdir -p $prefix/lib
$SUDO mkdir -p $prefix/bin

$SUDO cp lib/*.mod $prefix/include
$SUDO cp lib/libwgrib2.a $prefix/lib
$SUDO cp wgrib2/wgrib2 $prefix/bin

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
