using Test
using TestItems
using TestItemRunner

@run_package_tests

@testsnippet Setup begin
    using CatchaMouse16
    using CatchaMouse16.DimensionalData
    import CatchaMouse16.testdata, CatchaMouse16.testoutput, CatchaMouse16.testnames
    using Test
    using StatsBase
    using BenchmarkTools

    function isnearlyequalorallnan(a::AbstractArray, b::AbstractArray)
        replace!(a, NaN => 0.0)
        replace!(b, NaN => 0.0)
        all(isapprox.(a, b, atol = 1e-6))
    end
    function isnearlyequalorallnan(a::Real, b::Real)
        isapprox(a, b, atol = 1e-6) || (isnan(a) && isnan(b))
    end
    X = randn(1000, 100)
end

# Test catchaMouse16, time series by time series
println("Testing sample datasets")

# Test catchaMouse16 on a matrix
println("Testing 1000×100 array input")
@testitem "Matrices" setup=[Setup] begin
    X = randn(1000, 100)
    @test @time catchaMouse16(X) isa FeatureMatrix
end

# Test short name version is the same as the full version
println("Testing short names, c16")
@testitem "Short names" setup=[Setup] begin
    @test parent(catchaMouse16(X)) == parent(c16(X))
end

println("Testing 1000×20×20 array input")
@testitem "Arrays" setup=[Setup] begin
    X = randn(1000, 20, 20)
    @test @time catchaMouse16(X) isa FeatureArray{T, 3} where {T}
end

println("Testing FeatureArray indexing")
@testitem "FeatureArray indexing" setup=[Setup] begin
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
@testitem "DimArrays" setup=[Setup] begin
    x = DimArray(randn(1000), (Dim{:x}(1:1000),))
    @test first(AC_nl_035(x)) == AC_nl_035(x |> vec)
    @test length(AC_nl_035(x)) == 1
    @test catchaMouse16(x) == catchaMouse16(x |> vec)
end

println("Testing SuperFeatures")
@testitem "SuperFeatures" setup=[Setup] begin
    𝐱 = rand(1000, 2)
    # CatchaMouse16.zᶠ(𝐱)
    μ = SuperFeature(CatchaMouse16.mean, :μ,
                     "Mean value of the z-scored time series", ["0"], CatchaMouse16.zᶠ)
    σ = SuperFeature(CatchaMouse16.std, :σ,
                     "Standard deviation of the z-scored time series", ["1"],
                     CatchaMouse16.zᶠ)
    𝒇 = SuperFeatureSet([μ, σ])
    @test all(isapprox.(𝒇(𝐱), [0.0 0.0; 1.0 1.0]; atol = 1e-9))
end

println("Testing CatchaMouse16 SuperFeatures")
@testitem "CatchaMouse16 SuperFeatures" setup=[Setup] begin
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

@testitem "Multithreading" setup=[Setup] begin
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
end

@testitem "Types" setup=[Setup] begin
    X = rand(Int16, 1000, 10, 10)
    _F = catchaMouse16(X)
    @test eltype(_F) <: Float64
    for T in [Int, Int32, Float32, Float64]
        F = catchaMouse16(T.(X))
        @test eltype(F) <: Float64
        @test F≈_F rtol=1e-4
    end
end

println("Testing performance")
@testitem "Performance" setup=[Setup] begin
    @inferred CatchaMouse16.catchaMouse16(randn(1000))

    dataset = randn(10000000)
    fname = :AC_nl_035
    feature = eval(fname)

    m = CatchaMouse16._ccall(fname, Float64)
    t = @timed m(dataset)
    t = @timed m(dataset)
    tm = t.time
    @test t.bytes < 500

    t = @timed CatchaMouse16._catchaMouse16(dataset, fname)
    t = @timed CatchaMouse16._catchaMouse16(dataset, fname)
    @test t.time≈tm rtol=1 # The nancheck takes some time
    @test t.bytes < 500

    m = getmethod(CatchaMouse16.catchaMouse16_raw[fname])
    t = @timed m(dataset)
    t = @timed m(dataset)
    @test t.time≈tm rtol=1
    @test t.bytes < 500
    tf = t.time

    m = CatchaMouse16.z_score
    ta = @benchmark $m($dataset)
    m = CatchaMouse16.zᶠ
    tb = @benchmark $m($dataset)
    @test median(ta).time≈median(tb).time rtol=0.1
    tz = median(tb).time / 1e9

    m = feature |> getmethod
    t = @timed m(dataset)
    t = @timed m(dataset)
    @test t.time≈(tm + tz) rtol=1 # Feature time + zscore time
    @test t.bytes < Base.sizeof(dataset) + 5000 # Just one deepcopy of the dataset, for the zscore
end
