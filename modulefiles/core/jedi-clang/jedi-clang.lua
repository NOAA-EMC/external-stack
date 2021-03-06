help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

family("MetaCompiler")

conflict(pkgName)
conflict("jedi-intel","jedi-gnu")

local compiler = pathJoin("clang",pkgVersion)
load(compiler)
prereq(compiler)

local opt = os.getenv("JEDI_OPT") or os.getenv("OPT") or "/opt/modules"
local mpath = pathJoin(opt,"modulefiles/compiler","clang",pkgVersion)
prepend_path("MODULEPATH", mpath)

setenv("FC",  "gfortran")
setenv("CC",  "clang")
setenv("CXX", "clang++")
setenv("LD",  "clang")
setenv("SERIAL_FC",  "gfortran")
setenv("SERIAL_CC",  "clang")
setenv("SERIAL_CXX", "clang++")

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Compiler")
whatis("Description: clang/gfortran compiler configuration")
