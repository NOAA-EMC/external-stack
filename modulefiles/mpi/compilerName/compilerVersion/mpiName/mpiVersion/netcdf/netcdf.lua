help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,2)
local mpiNameVer   = hierA[1]
local compNameVer  = hierA[2]
local mpiNameVerD  = mpiNameVer:gsub("/","-")
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

load("hdf5","pnetcdf")
prereq("hdf5","pnetcdf")

local opt = os.getenv("JEDI_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,mpiNameVerD,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("MANPATH", pathJoin(base,"share","man"))

setenv("NETCDF", base)
setenv("NETCDF_ROOT", base)
setenv("NETCDF_INCLUDES", pathJoin(base,"include"))
setenv("NETCDF_LIBRARIES", pathJoin(base,"lib"))
setenv("NETCDF_VERSION", pkgVersion)

setenv("NetCDF", base)
setenv("NetCDF_ROOT", base)
setenv("NetCDF_INCLUDES", pathJoin(base,"include"))
setenv("NetCDF_LIBRARIES", pathJoin(base,"lib"))
setenv("NetCDF_VERSION", pkgVersion)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: NetCDF4 C, CXX and Fortran library")
