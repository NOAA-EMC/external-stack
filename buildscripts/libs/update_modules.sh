#!/bin/bash

# This script creates a module file for a given package
# based on a pre-existing template
#
# Arguments:
# $1 = module path: valid options are core, compiler, or mpi
# $2 = package name
# $3 = package version

function update_modules {
    case $1 in
        core     )
            tmpl_file=$JEDI_STACK_ROOT/modulefiles/core/$2/$2.lua
            to_dir=$OPT/modulefiles/core ;;
        compiler )
            tmpl_file=$JEDI_STACK_ROOT/modulefiles/compiler/compilerName/compilerVersion/$2/$2.lua
            to_dir=$OPT/modulefiles/compiler/$COMPILER ;;
        mpi      )
            tmpl_file=$JEDI_STACK_ROOT/modulefiles/mpi/compilerName/compilerVersion/mpiName/mpiVersion/$2/$2.lua
            to_dir=$OPT/modulefiles/mpi/$COMPILER/$MPI ;;
        *) echo "ERROR: INVALID MODULE PATH, ABORT!"; exit 1 ;;
    esac

    [[ -e $tmpl_file ]] || ( echo "ERROR: $tmpl_file NOT FOUND!  ABORT!"; exit 1 )

    # For discover, write the modulfile manually if the directory already exists
    #[[ -d $to_dir ]] || ( echo "ERROR: $mod_dir MODULE DIRECTORY NOT FOUND!  ABORT!"; exit 1 )
    #[[ -d $to_dir/$2 ]] && ( echo "Modulefile directory already exists"; exit 0 )
    exit 0

    cd $to_dir
    $SUDO mkdir -p $2; cd $2
    $SUDO cp $tmpl_file $3.lua

    # Make the latest installed version the default
    [[ -e default ]] && $SUDO rm -f default
    $SUDO ln -s $3.lua default

}

function no_modules {

    # this function defines environment variables that are
    # normally done by the modules.  It's mainly intended
    # for use in generating the containers    
    
    compilerName=$(echo $COMPILER | cut -d/ -f1)
    mpiName=$(echo $MPI | cut -d/ -f1)

    # these can be specified in the config file
    # so these should be considered defaults
    
    case $compilerName in
	gnu   )
	    export SERIAL_CC=${SERIAL_CC:-"gcc"}
	    export SERIAL_CXX=${SERIAL_CXX:-"g++"}
	    export SERIAL_FC=${SERIAL_FC:-"gfortran"}
	    ;;
	intel )
	    export SERIAL_CC=${SERIAL_CC:-"icc"}
	    export SERIAL_CXX=${SERIAL_CXX:-"icpc"}
	    export SERIAL_FC=${SERIAL_FC:-"ifort"}
	    ;;
	clang )
	    export SERIAL_CC=${SERIAL_CC:-"clang"}
	    export SERIAL_CXX=${SERIAL_CXX:-"clang++"}
	    export SERIAL_FC=${SERIAL_FC:-"gfortran"}
	    ;;
	*     ) echo "Unknown compiler option = $compilerName, ABORT!"; exit 1 ;;
    esac    

    case $mpiName in
	openmpi)
	    export MPI_CC=${MPI_CC:-"mpicc"}
	    export MPI_CXX=${MPI_CXX:-"mpicxx"}
	    export MPI_FC=${MPI_FC:-"mpifort"}
	    ;;
	mpich  )
	    export MPI_CC=${MPI_CC:-"mpicc"}
	    export MPI_CXX=${MPI_CXX:-"mpicxx"}
	    export MPI_FC=${MPI_FC:-"mpifort"}
	    ;;
	impi   )
	    export MPI_CC=${MPI_CC:-"mpiicc"}
	    export MPI_CXX=${MPI_CXX:-"mpiicpc"}
	    export MPI_FC=${MPI_FC:-"mpiifort"}
	    ;;
	*     ) echo "Unknown MPI option = $MPIName, ABORT!"; exit 1 ;;
    esac    

    config_file="${JEDI_STACK_ROOT}/buildscripts/config/config_${1:-"container"}.sh"

    set +x
    # look for build items that are set in the config file
    while IFS= read -r line ; do
        if [[ $(echo $line | grep "STACK_BUILD" | cut -d= -f2) =~ [yYtT] ]]; then
            pkg=$(echo $line | cut -d= -f1 | cut -d_ -f3)
            eval export ${pkg}_ROOT="/usr/local"
        fi
    done < $config_file    
    set -x
    
}

export -f update_modules
export -f no_modules    
