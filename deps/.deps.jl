# This is an auto-generated file; do not edit

# Pre-hooks

# Macro to load a library
macro checked_lib(libname, path)
    path = string(path)
    ((Base.Libdl.dlopen_e)(path) == C_NULL) && error("Unable to load \n\n$libname ($path)\n\nPlease re-run Pkg.build(package), and restart Julia.")
    quote const $(esc(libname)) = $path end
end

include("constants.jl")

const csdp = dlpath

info("Using $csdp")

# Load-hooks

