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

always_load("odc")
prereq("odc")

local opt = os.getenv("JEDI_OPT") or os.getenv("OPT") or "/opt/modules"
local base = pathJoin(opt,compNameVerD,mpiNameVerD,pkgName,pkgVersion)
local odc_lib = pathJoin(os.getenv("odc_ROOT"), "lib")
local olib_pattern = pathJoin(base, "lib/python3*/site-packages")
local pyodc_lib = capture(string.format("echo %s", olib_pattern))

prepend_path("PATH", pathJoin(base,"bin"))
prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("PYTHONPATH", odc_lib)
prepend_path("PYTHONPATH", pyodc_lib)

setenv( "pyodc_ROOT", base)
setenv( "pyodc_PATH", base)
setenv( "pyodc_VERSION", pkgVersion)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Toolkit")
whatis("Description: ECMWF API to ODB2 data files")
