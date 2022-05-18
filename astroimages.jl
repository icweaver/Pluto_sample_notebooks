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
implot(img)

# ╔═╡ 67e9e89e-7442-4d96-b8e2-fadb900a8cc3
@mdx """
In the background, AstroImages.jl calls the generic plotting package [Plots.jl](https://docs.juliaplots.org/stable/), and automatically adds a colorbar and tick marks for us. The relevant transformations from pixel space to world coordinates (in this case RA and Dec) are also automatically applied based on the [WCS](https://www.atnf.csiro.au/people/mcalabre/WCS/) information stored in the image of our fits file.

For more information about this package and its different capabilities, be sure to check out the [demo AstroImages.jl notebook]()!

!!! warning "TODO"
	Add a demo notebook from Will?
"""

# ╔═╡ d4552736-159b-4c6a-9a97-ef57024333f7
@mdx """
### Coordinate conversion aside

Now that we have a nice way to visualize astronomical data with coordinate-aware transformations, let's compose this with regular plot commands from Plots.jl. If we turn off the axes transformations, we recover the typical pixel space information stored in our FITs file:
"""

# ╔═╡ 6fd6108a-dc97-42ed-a722-bc74c19a0bde
implot(img; wcsticks=false, framestyle=:grid)

# ╔═╡ b8e06c27-5504-41d1-b07c-c5259ff2681f
@mdx """
By default, the origin is in the bottom-left corner and increases to the right and up. Since this is a standard Plots.jl figure object, we can plot a test point on top of it [in the usual way](https://docs.juliaplots.org/latest/basics/):
"""

# ╔═╡ 12b9a88f-2f9a-4744-ba69-496545a0dac0
let
	p = implot(img; wcsticks=false, framestyle=:grid)
	scatter!(p, [500], [400]; ms=10, msw=0)
end

# ╔═╡ aa60557e-faf0-4058-96fd-128ca093c773
@mdx """
We can go the other direction (from world cordinate space to pixel space) in the following two stages:

1. First, we use [AstroAngles.jl](https://github.com/JuliaAstro/AstroAngles.jl) to conveniently convert RA and Dec formatted input to their equivalent values in degrees for us
1. Next, we pass these values to the `world_to_pix` function exported by `AstroImages.jl` to make the WCS transformations for us in our final plot

!!! warning "TODO"
	Check if degrees are being used internally for all cases
"""

# ╔═╡ 5165c5b5-7b54-4e46-9886-c67b328dc6b6
@which pix_to_world

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
# ╟─d4552736-159b-4c6a-9a97-ef57024333f7
# ╠═6fd6108a-dc97-42ed-a722-bc74c19a0bde
# ╟─b8e06c27-5504-41d1-b07c-c5259ff2681f
# ╠═12b9a88f-2f9a-4744-ba69-496545a0dac0
# ╟─aa60557e-faf0-4058-96fd-128ca093c773
# ╠═5165c5b5-7b54-4e46-9886-c67b328dc6b6
# ╠═05adb41a-5481-478f-9f88-9f94df4fe4b4
# ╠═2d5365c9-c7d9-4d14-b074-f77b39baec02
# ╠═55f3b616-ecf6-418a-9bf3-beb5e3a8e555
# ╠═f19b358c-8506-11ec-252c-c39dcd644d06
