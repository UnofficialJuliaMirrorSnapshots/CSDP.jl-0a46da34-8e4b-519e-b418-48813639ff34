using BinDeps
using LinearAlgebra, Libdl

@BinDeps.setup

include("constants.jl")
include("compile.jl")

# @info "libname = $libname"
blas = library_dependency("libblas", alias=["libblas.dll"])
lapack = library_dependency("liblapack", alias=["liblapack.dll"])
depends = JULIA_LAPACK ? [] : [blas, lapack]

# LaPack/BLAS dependencies
if !JULIA_LAPACK
    @static if Sys.iswindows()
        # wheel = "numpy/windows-wheel-builder/raw/master/atlas-builds"
        # atlas = "https://github.com/$wheel"
        # atlasdll = "/atlas-3.11.38-sse2-64/lib/numpy-atlas.dll"
        # download("https://raw.githubusercontent.com/$wheel/$atlasdll"),
        #           "$libdir/libatlas.dll")
        ## at the end ...
        # push!(BinDeps.defaults, BuildProcess)
    end
end

csdp = library_dependency("csdp", aliases=[libname], depends=depends)

provides(Sources, URI(download_url), csdp, unpacked_dir=csdpversion)

provides(BuildProcess,
         (@build_steps begin
             GetSources(csdp)
             CreateDirectory(libdir)
             CreateDirectory(builddir)
             @build_steps begin
                  ChangeDirectory(srcdir)
                  patch_int
                  compile_objs
             end
         end),
         [csdp])

# Prebuilt DLLs for Windows
provides(Binaries,
   URI("https://github.com/EQt/winlapack/blob/49454aee32649dc52c5b64f408a17b5270bd30f4/win-csdp-$(Sys.WORD_SIZE).7z?raw=true"),
   [csdp, lapack, blas], unpacked_dir="usr", os = :Windows)

@BinDeps.install Dict(:csdp => :csdp)
