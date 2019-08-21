using CSDP

using Test
using LinearAlgebra # For Diagonal

@testset "Interact with BLAS" begin
    vec = Cdouble[1.0, 2.0, 0.0, -1.0]
    l = length(vec)
    inc = 1
    n1 = ccall((BLAS.@blasfunc(dasum_), LinearAlgebra.BLAS.libblas),
               Cdouble,
               (Ref{LinearAlgebra.BlasInt}, Ptr{Cdouble},
                Ref{LinearAlgebra.BlasInt}),
               l, vec, inc)
    @test abs(n1 - 4) < 1e-15
end

@testset "Call libcsdp.norm1" begin
    vec = Cdouble[1.0, 2.0, 0.0, -1.0]
    try
        n1 = ccall((:norm1, CSDP.csdp),
                   Cdouble,
                   (Cint, Ptr{Cdouble}),
                   length(vec), vec)
        @test abs(n1 - 4) < 1e-15
    catch
        println("n1 = $n1, vec=$vec, length(vec)=$(length(vec))")
        rethrow()
    end
end

@testset "Example" begin
    cd(joinpath(dirname(dirname(pathof(CSDP))), "examples")) do
        include(joinpath(pwd(), "example.jl"))
        @test size(X) == (7, 7)
        @test length(y) == 2
        @test size(Z) == (7, 7)
        X✓ = [3 3  0 0 0 0 0;
              3 3  0 0 0 0 0;
              0 0 16 0 0 0 0;
              0 0  0 0 0 0 0;
              0 0  0 0 0 0 0;
              0 0  0 0 0 0 0;
              0 0  0 0 0 0 0] / 24
        @test norm(convert(AbstractArray, X) - X✓) < 1e-6
        y✓ = [3, 4] / 4
        @test norm(convert(AbstractArray, y) - y✓) < 1e-6
        Z✓ = [1 -1 0 0 0 0 0;
             -1  1 0 0 0 0 0;
              0  0 0 0 0 0 0;
              0  0 0 8 0 0 0;
              0  0 0 0 8 0 0;
              0  0 0 0 0 3 0;
              0  0 0 0 0 0 4] / 4
        @test norm(convert(AbstractArray, Z) - Z✓) < 1e-6
    end
end

@testset "Options" begin
    @test CSDP.paramstruc(Dict(:axtol => 1e-7)).axtol == 1e-7
end

@testset "MathOptInterface" begin
    include("MOI_wrapper.jl")
end
@testset "MathProgBase" begin
    include("MPB_wrapper.jl")
end
