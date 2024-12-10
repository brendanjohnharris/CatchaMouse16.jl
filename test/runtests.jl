using CatchaMouse16
using CatchaMouse16.DimensionalData
import CatchaMouse16.testdata, CatchaMouse16.testoutput, CatchaMouse16.testnames
using Test
using StatsBase
# using BenchmarkTools

function isnearlyequalorallnan(a::AbstractArray, b::AbstractArray)
    replace!(a, NaN => 0.0)
    replace!(b, NaN => 0.0)
    all(isapprox.(a, b, atol = 1e-6))
end
function isnearlyequalorallnan(a::Real, b::Real)
    isapprox(a, b, atol = 1e-6) || (isnan(a) && isnan(b))
end

# Test features one by one
println("Testing individual features")
@testset "Feature $(getname(f))" for f in catchaMouse16
    @inferred CatchaMouse16._catchaMouse16(testdata[:test], getname(f))
    @inferred CatchaMouse16._catchaMouse16(randn(1000, 10), getname(f))
    # @test isnearlyequalorallnan(f(testdata[:test]), testoutput[:test][getname(f)])
    @test !isnan(f(randn(1000)))
end

# Test catchaMouse16, time series by time series
catchaMouse16(testdata[:test])
println("Testing sample datasets")

# Test catchaMouse16 on a matrix
println("Testing 1000×100 array input")
catchaMouse16(randn(10, 10))
X = randn(1000, 100)
@testset "Matrices" begin
    @test @time catchaMouse16(X) isa FeatureMatrix
end

# Test short name version is the same as the full version
println("Testing short names, c16")
@testset "Short names" begin
    @test parent(catchaMouse16(X)) == parent(c16(X))
end

println("Testing 1000×20×20 array input")
catchaMouse16(randn(10, 10, 10))
X = randn(1000, 20, 20)
@testset "Arrays" begin
    @test @time catchaMouse16(X) isa FeatureArray{T, 3} where {T}
end

println("Testing FeatureArray indexing")

@testset "FeatureArray indexing" begin
    𝑓s = [:AC_nl_035, :AC_nl_036]
    𝑓 = FeatureSet([AC_nl_036, AC_nl_035])

    X = randn(1000)
    F = catchaMouse16(X)
    @test F[𝑓] == F[𝑓s][end:-1:1]
    @test F[𝑓] == F[[2, 1]]
    @test all(F[𝑓s] .== F[1:2]) # Importantly, F[𝑓s, :] is NOT SUPPORTED

    X = randn(1000, 200)
    F = catchaMouse16(X)
    @test F[𝑓] == F[𝑓s][end:-1:1, :]
    @test F[𝑓] == F[𝑓, :] == F[[2, 1], :]
    @test F[𝑓s] == F[𝑓s, :] == F[1:2, :]

    X = randn(1000, 20, 20)
    F = catchaMouse16(X)
    @test F[𝑓] == F[𝑓s][end:-1:1, :, :]
    @test F[𝑓] == F[𝑓, :, :] == F[[2, 1], :, :]
    @test F[𝑓s] == F[𝑓s, :, :] == F[1:2, :, :]
end

println("Testing Feature evaluation with DimArrays")
@testset "DimArrays" begin
    x = DimArray(randn(1000), (Dim{:x}(1:1000),))
    @test first(AC_nl_035(x)) == AC_nl_035(x |> vec)
    @test length(AC_nl_035(x)) == 1
    @test catchaMouse16(x) == catchaMouse16(x |> vec)
end

println("Testing SuperFeatures")
@testset "SuperFeatures" begin
    𝐱 = rand(1000, 2)
    # CatchaMouse16.zᶠ(𝐱)
    μ = SuperFeature(CatchaMouse16.mean, :μ, ["0"],
                     "Mean value of the z-scored time series",
                     super = CatchaMouse16.zᶠ)
    σ = SuperFeature(CatchaMouse16.std, :σ, ["1"],
                     "Standard deviation of the z-scored time series";
                     super = CatchaMouse16.zᶠ)
    𝒇 = SuperFeatureSet([μ, σ])
    @test all(isapprox.(𝒇(𝐱), [0.0 0.0; 1.0 1.0]; atol = 1e-9))
end

println("Testing CatchaMouse16 SuperFeatures")
@testset "CatchaMouse16 SuperFeatures" begin
    catchaMouse16² = vcat(fill(catchaMouse16, 22)...)
    catchaMouse16_raw² = vcat(fill(CatchaMouse16.catchaMouse16_raw, 22)...)
    X = rand(1000, 10)
    @test catchaMouse16²(X) !== catchaMouse16_raw²(X)
    @test catchaMouse16_raw²(X) !==
          catchaMouse16_raw²(mapslices(CatchaMouse16.z_score, X, dims = 1))
    @test catchaMouse16²(X) ==
          catchaMouse16_raw²(mapslices(CatchaMouse16.z_score, X, dims = 1))
    # @test catchaMouse16²[1:10] isa SuperFeatureSet # Ideally
    @test catchaMouse16_raw²[1:10](X) == catchaMouse16_raw²(X)[1:10, :]

    # @benchmark catchaMouse16_raw²(X)
    # @benchmark catchaMouse16²(X)
    # @benchmark catchaMouse16_raw²(mapslices(CatchaMouse16.z_score, X, dims=1))
    # @benchmark mapslices(CatchaMouse16.z_score, X, dims=1)
end

@testset "Multithreading" begin
    X = randn(10000)
    meths = CatchaMouse16.featurenames
    cres = zeros(size(X)[1], length(meths))
    window = 100
    f(X) =
        for j in eachindex(meths)
            Threads.@threads for i in 1:(size(X, 1) - window)
                @inbounds cres[i + window, j] = catchaMouse16[meths[j]](X[i:(i + window)])
            end
        end

    g(X) = Threads.@threads for i in 1:(size(X, 1) - window)
        @inbounds cres[i + window, :] = catchaMouse16[meths](X[i:(i + window)])
    end

    h(X) = catchaMouse16[meths]([X[i:(i + window)] for i in 1:(size(X, 1) - window)])

    i(X) = catchaMouse16[meths](@views [X[i:(i + window)]
                                        for i in 1:(size(X, 1) - window)])

    # BenchmarkTools.DEFAULT_PARAMETERS.seconds = 5
    # f(X) # @benchmark f(X)
    # g(X) # @benchmark g(X)
    # h(X) # @benchmark h(X)
    # i(X) # @benchmark i(X)
    # # using PProf
    # # using Profile
    # # Profile.clear()
    # # @profile i(X)
    # # pprof()
    # # @profview i(X)
end

@testset "Types" begin
    X = rand(Int16, 1000, 10, 10)
    _F = catchaMouse16(X)
    @test eltype(_F) <: Float64
    for T in [Int, Int32, Float32, Float64]
        F = catchaMouse16(T.(X))
        @test eltype(F) <: Float64
        @test F ≈ _F rtol=1e-6
    end
end
