### A Pluto.jl notebook ###
# v0.19.4

using Markdown
using InteractiveUtils

# ╔═╡ f19b358c-8506-11ec-252c-c39dcd644d06
begin
	import Pkg
	Pkg.activate(Base.current_project())
	
	using AstroImages, PlutoUI, Plots
end

# ╔═╡ 05adb41a-5481-478f-9f88-9f94df4fe4b4
using UnitfulAstro, UnitfulAstro.Unitful

# ╔═╡ 2d5365c9-c7d9-4d14-b074-f77b39baec02
using AstroImages.AstroAngles

# ╔═╡ 59584fac-598d-4752-82fa-840378d70c08
Pkg.status()

# ╔═╡ bb2425be-3e6a-456d-bad2-e665dc7408aa
fname = download("http://data.astropy.org/tutorials/FITS-images/HorseHead.fits")

# ╔═╡ a5d80eed-fb12-4980-82db-800a1c4dba49
img = load(fname)

# ╔═╡ 5fcff0be-3d80-4423-a239-2a00aa376db3
begin
	implot(img; wcsticks=true, framestyle=:grid)
	X, Y = world_to_pix(img, [hms"5 41 00"deg, dms"-2 28"deg])
	scatter!([X], [Y]; ms=10, msw=0)
end

# ╔═╡ 0ce5fe45-dd19-4891-89a5-2c9f18daeed4
l = @layout [
	img{0.25w} colorbar{0.15h}
]

# ╔═╡ 9dc84393-af39-4a3d-a878-ab4e924db480
l

# ╔═╡ Cell order:
# ╠═f19b358c-8506-11ec-252c-c39dcd644d06
# ╠═59584fac-598d-4752-82fa-840378d70c08
# ╠═bb2425be-3e6a-456d-bad2-e665dc7408aa
# ╠═a5d80eed-fb12-4980-82db-800a1c4dba49
# ╠═5fcff0be-3d80-4423-a239-2a00aa376db3
# ╠═9dc84393-af39-4a3d-a878-ab4e924db480
# ╠═0ce5fe45-dd19-4891-89a5-2c9f18daeed4
# ╠═05adb41a-5481-478f-9f88-9f94df4fe4b4
# ╠═2d5365c9-c7d9-4d14-b074-f77b39baec02
