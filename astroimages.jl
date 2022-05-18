### A Pluto.jl notebook ###
# v0.19.4

#> [frontmatter]
#> title = "ExoFinder.jl"
#> description = "Let's find some worlds!"

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

# ╔═╡ 55f3b616-ecf6-418a-9bf3-beb5e3a8e555
using MarkdownLiteral: @mdx

# ╔═╡ 3845b39a-a637-4d2b-b2b9-f4ac0294f0e9
@mdx """
# ExoFinder 🪐

In this notebook, we will build a simple map showing the locations of known exoplanets in the night sky. The final product will look like this:
"""

# ╔═╡ e58691c1-98ed-4e75-a5bb-e03102e62def
md"""
This demo uses the following packages: 
"""

# ╔═╡ 3ea72aeb-356c-4fd1-b228-f0cf0cba2df7
with_terminal() do
	Pkg.status()
end

# ╔═╡ 6207daa3-fde6-4535-9ef3-d1e4a762a14d
@mdx """
## Sky map 🗺️

First, let's set up a way to create a coordinate-aware plot of a patch of the sky. We will accomplish this with the handy [AstroImages.jl](https://github.com/JuliaAstro/AstroImages.jl) package. First, we download a sample image (stored in the [FITS](https://en.wikipedia.org/wiki/FITS) file format):

!!! warning "TODO"
	Update with Will's [PR](https://github.com/JuliaAstro/AstroImages.jl/pull/30)
"""

# ╔═╡ bb2425be-3e6a-456d-bad2-e665dc7408aa
fname = download("http://data.astropy.org/tutorials/FITS-images/HorseHead.fits")

# ╔═╡ a5d80eed-fb12-4980-82db-800a1c4dba49
img = load(fname);

# ╔═╡ 5fcff0be-3d80-4423-a239-2a00aa376db3
let
	implot(img; wcsticks=true, framestyle=:grid)
	X, Y = world_to_pix(img, [hms"5 41 00"deg, dms"-2 28"deg])
	scatter!([X], [Y]; ms=10, msw=0)
end

# ╔═╡ 8830d13c-04e7-4333-babc-10bb267993fe
@mdx """
And then just plot it!
"""

# ╔═╡ 8762e1a5-505b-4eed-8863-35171e8cc8e1
p = implot(img)

# ╔═╡ 67e9e89e-7442-4d96-b8e2-fadb900a8cc3
@mdx """
In the background, AstroImages.jl calls the generic plotting package [Plots.jl](https://docs.juliaplots.org/stable/), and automatically adds a colorbar and tick marks for us. The relevant transformations from pixel space to world coordinates (in this case RA and Dec) are also automatically applied based on the [WCS](https://www.atnf.csiro.au/people/mcalabre/WCS/) information stored in the image of our fits file.

For more information about this package and its different capabilities, be sure to check out the [demo AstroImages.jl notebook]()!

!!! warning "TODO"
	Add a demo notebook from Will?
"""

# ╔═╡ Cell order:
# ╟─3845b39a-a637-4d2b-b2b9-f4ac0294f0e9
# ╟─5fcff0be-3d80-4423-a239-2a00aa376db3
# ╟─e58691c1-98ed-4e75-a5bb-e03102e62def
# ╟─3ea72aeb-356c-4fd1-b228-f0cf0cba2df7
# ╟─6207daa3-fde6-4535-9ef3-d1e4a762a14d
# ╠═bb2425be-3e6a-456d-bad2-e665dc7408aa
# ╠═a5d80eed-fb12-4980-82db-800a1c4dba49
# ╟─8830d13c-04e7-4333-babc-10bb267993fe
# ╠═8762e1a5-505b-4eed-8863-35171e8cc8e1
# ╟─67e9e89e-7442-4d96-b8e2-fadb900a8cc3
# ╠═05adb41a-5481-478f-9f88-9f94df4fe4b4
# ╠═2d5365c9-c7d9-4d14-b074-f77b39baec02
# ╠═55f3b616-ecf6-418a-9bf3-beb5e3a8e555
# ╠═f19b358c-8506-11ec-252c-c39dcd644d06
