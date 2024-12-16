module CatchaMouse16
using catchaMouse16_jll
using DimensionalData
using Libdl
using Reexport
using TimeseriesFeatures
using LinearAlgebra
import Statistics: mean, std, cov

function __init__()
    catchaMouse16_jll.__init__()
    lib = dlopen(libcatchaMouse16)
    global fbindings = Dict{Symbol, Ptr{Cvoid}}(f => dlsym(lib, f)
                                                for f in featurenames)
end

@reexport using TimeseriesFeatures
import TimeseriesFeatures: zᶠ, z_score

include("metadata.jl")
include("testdata.jl")

nancheck(𝐱::AbstractVector) = length(𝐱) < 3 || any(isnan, 𝐱) || any(isinf, 𝐱)

function _ccall(fName::Symbol, ::Type{T}) where {T <: Integer}
    f(𝐱)::T = ccall(fbindings[fName], Cint, (Ptr{Array{Cint}}, Cint), 𝐱, Int(size(𝐱, 1)))
end
function _ccall(fName::Symbol, ::Type{T}) where {T <: AbstractFloat}
    f(𝐱)::T = ccall(fbindings[fName], Cdouble, (Ptr{Array{Cdouble}}, Cint), 𝐱,
                    Int(size(𝐱, 1)))
end

function __catchaMouse16(𝐱::AbstractVector, fName::Symbol)::Float64
    nancheck(𝐱) && return NaN
    _ccall(fName, Cdouble)(𝐱)
end

"""
    _catchaMouse16(𝐱::AbstractArray{Float64}, fName::Symbol)
    _catchaMouse16(fName::Symbol, 𝐱::AbstractArray{Float64})
Evaluate the feature `fName` on the single time series `𝐱`. See `CatchaMouse16.featuredescriptions` for a summary of the 22 available time series features. Time series with NaN or Inf values will produce NaN feature values.

# Examples
```julia
𝐱 = CatchaMouse16.testdata[:test]
CatchaMouse16._catchaMouse16(𝐱, :AC_nl_035)
```
"""
function _catchaMouse16(𝐱::AbstractVector, fName::Symbol)::Float64
    __catchaMouse16(𝐱, fName)
end
function _catchaMouse16(X::AbstractMatrix, fName::Symbol)::Matrix{Float64}
    mapslices(𝐱 -> __catchaMouse16(𝐱, fName), X, dims = [1])
end

const features = map(featurenames) do name
    function feature(𝐱::AbstractVector{<:Real})::Float64
        nancheck(𝐱) && return NaN
        _ccall(name, Cdouble)(convert(Vector{Float64}, 𝐱))
    end
end

"""
The set of CatchaMouse16 features without a preliminary z-score
"""
catchaMouse16_raw = FeatureSet(features, featurenames, featuredescriptions, featurekeywords)

"""
    catchaMouse16(𝐱::Vector)
    catchaMouse16(X::Array)
    catchaMouse16[featurename::Symbol](X::Array)
Evaluate all features for a time series vector `𝐱` or the columns of an array `X`.
`catchaMouse16` is a FeatureSet, which means it can be indexed by feature names (as symbols) to return a subset of the available features.
`getnames(catchaMouse16)`, `getkeywords(catchaMouse16)` and `getdescriptions(catchaMouse16)` will also return feature names, keywords and descriptions respectively.
Features are returned in a `FeatureArray`, in which array rows are annotated by feature names. A `FeatureArray` can be converted to a regular array with `Array(F)`.

# Examples
```julia
𝐱 = CatchaMouse16.testdata[:test]
𝐟 = catchaMouse16(𝐱)

X = randn(100, 10)
F = catchaMouse16(X)
F = catchaMouse16[:AC_nl_035](X)
```
"""
catchaMouse16 = SuperFeatureSet(features, featurenames, featuredescriptions,
                                featurekeywords, zᶠ)
export catchaMouse16

for f in featurenames
    eval(quote
             $f = catchaMouse16[$(Meta.quot(f))]
             export $f
         end)
end

"""
    AC_nl_035(x::AbstractVector{Union{Float64, Int}}) # For example
An alternative to `catchaMouse16(:AC_nl_035](x)`.
All features, such as `AC_nl_035`, are exported as Features and can be evaluated by calling their names.

# Examples
```julia
𝐱 = CatchaMouse16.testdata[:test]
f = AC_nl_035(𝐱)
```
"""
AC_nl_035

"""
    c16
The CatchaMouse16 feature set with shortened names; see [`catchaMouse16`](@ref).
"""
c16 = SuperFeatureSet(features, short_featurenames, featuredescriptions, featurekeywords,
                      zᶠ)
export c16

end
