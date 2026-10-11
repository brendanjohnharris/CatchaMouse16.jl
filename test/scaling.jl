using CatchaMouse16
using Plots
using MoreMaps

chart = Chart()
function timeCatchaMouse16(𝒳)
    t⃗ = [(@info size(𝐱); @timed catchaMouse16(𝐱; chart)) for 𝐱 in 𝒳]
    ([x.time for x in t⃗], [x.bytes for x in t⃗])
end;
timeCatchaMouse16([randn(1000)])

N⃗ = Int.(round.(exp10.(0.9:0.1:5)));

## Single-threaded
𝒳 = [randn(N) for N in N⃗];
t⃗, b⃗ = timeCatchaMouse16(𝒳);

gray = :gray50
p = plot(N⃗, t⃗, scale = :log10, label = :none, color = :cornflowerblue,
         markerstrokecolor = :cornflowerblue, markersize = 2, marker = :o,
         right_margin = 15Plots.mm, xlims = (1e1, 1e5),
         framestyle = :box, grid = :off)
plot!(xguide = "Time-series length (samples)", yguide = "Seconds per time series",
      minorticks = true,
      yforeground_color_guide = :cornflowerblue, dpi = 1200,
      background_color = :transparent, foreground_color_axis = gray,
      foreground_color_border = gray, foreground_color_text = gray,
      foreground_color_guide = gray, foreground_color_grid = gray)

plot!(twinx(), N⃗, b⃗ ./ (1024^2), scale = :log10, label = :none, color = :crimson,
      markersize = 2, marker = :o, markerstrokewidth = 0, grid = :off,
      yguide = "MiB per time series", yforeground_color_guide = :crimson, minorticks = true,
      xticks = nothing, markerstrokecolor = :crimson, xlims = (1e1, 1e5),
      foreground_color_axis = gray, foreground_color_border = gray,
      foreground_color_text = gray, foreground_color_guide = gray, framestyle = :box)

fname = joinpath(@__DIR__, "../scaling.png")
rm(fname, force = true)
savefig(p, fname)

## Multi-threaded
nsamples = 100
𝒳 = [randn(N, nsamples) for N in N⃗];
t⃗, b⃗ = timeCatchaMouse16(𝒳);
t⃗ = t⃗ ./ nsamples # Time per time series
b⃗ = b⃗ ./ nsamples # Memory per time series

gray = :gray50
p = plot(N⃗, t⃗, scale = :log10, label = :none, color = :cornflowerblue,
         markerstrokecolor = :cornflowerblue, markersize = 2, marker = :o,
         right_margin = 15Plots.mm, ylims = (10^(-5), 10^(-0.5)), xlims = (1e1, 1e5),
         grid = :off,
         framestyle = :box, yticks = exp10.(-5:1))
plot!(xguide = "Time-series length (samples)", yguide = "Seconds per time series",
      minorticks = true,
      yforeground_color_guide = :cornflowerblue, dpi = 1200,
      background_color = :transparent, foreground_color_axis = gray,
      foreground_color_border = gray, foreground_color_text = gray,
      foreground_color_guide = gray, foreground_color_grid = gray)

plot!(twinx(), N⃗, b⃗ ./ (1024^2), scale = :log10, label = :none, color = :crimson,
      markersize = 2, marker = :o, markerstrokewidth = 0, grid = :off,
      yguide = "MiB per time series", yforeground_color_guide = :crimson,
      minorticks = true,
      xticks = nothing, markerstrokecolor = :crimson, xlims = (1e1, 1e5),
      foreground_color_axis = gray, foreground_color_border = gray,
      foreground_color_text = gray, foreground_color_guide = gray, framestyle = :box)

fname = joinpath(@__DIR__, "../multithread_scaling.png")
rm(fname, force = true)
savefig(p, fname)
