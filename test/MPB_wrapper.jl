const solver = CSDP.CSDPSolver(printlevel=0)

import MathProgBase
@static if VERSION >= v"0.7-"
    const MPB_test_path = joinpath(dirname(pathof(MathProgBase)), "..", "test")
else
    const MPB_test_path = joinpath(Pkg.dir("MathProgBase"), "test")
end

@testset "Linear tests" begin
    include(joinpath(MPB_test_path, "linproginterface.jl"))
    linprogsolvertest(solver, 1e-6)
end

@testset "Conic tests" begin
    include(joinpath(MPB_test_path, "conicinterface.jl"))
    # FIXME fails on Windows 32 bits... Maybe I should put linear vars/cons
    # in a diagonal matrix in SemidefiniteModels.jl instead of many 1x1 blocks
    @static if !Compat.Sys.iswindows() || Sys.WORD_SIZE != 32
        @testset "Conic linear tests" begin
            coniclineartest(solver, duals=true, tol=1e-6)
        end

@testset "Conic SOC tests" begin
    conicSOCtest(CSDP.CSDPSolver(printlevel=0, write_prob="soc.prob"), duals=true, tol=1e-6)
end

# CSDP returns :Suboptimal for SOCRotated1
#        @testset "Conic SOC rotated tests" begin
#            conicSOCRotatedtest(solver, duals=true, tol=1e-6)
#        end
    end

    @testset "Conic SDP tests" begin
        conicSDPtest(solver, duals=false, tol=1e-6)
    end
end
