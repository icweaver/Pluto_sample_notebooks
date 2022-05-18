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
	using MarkdownLiteral: @mdx
end

# ╔═╡ 2d5365c9-c7d9-4d14-b074-f77b39baec02
using AstroImages.AstroAngles

# ╔═╡ cc2aaba1-4dfe-414f-8ace-71075e2f3bf5
using HTTP

# ╔═╡ ad40234c-474c-489e-b328-73fa5ecfb6e2
using HTTP.URIs

# ╔═╡ acdf51db-09e0-4e4c-b529-2db8030ea57c
using CSV, DataFramesMeta

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
## 🗺️ Sky map

First, let's set up a way to create a coordinate-aware plot of a patch of the sky. We will accomplish this with the handy [AstroImages.jl](https://github.com/JuliaAstro/AstroImages.jl) package. First, we download a sample image (stored in the [FITS](https://en.wikipedia.org/wiki/FITS) file format):

!!! warning "TODO"
	Update link with Will's [PR](https://github.com/JuliaAstro/AstroImages.jl/pull/30)
"""

# ╔═╡ bb2425be-3e6a-456d-bad2-e665dc7408aa
fname = download("http://data.astropy.org/tutorials/FITS-images/HorseHead.fits")

# ╔═╡ a5d80eed-fb12-4980-82db-800a1c4dba49
img = load(fname);

# ╔═╡ 5fcff0be-3d80-4423-a239-2a00aa376db3
let
	implot(img; wcsticks=true, framestyle=:grid)
	X, Y = world_to_pix(img, [hms"5 41 00"deg, dms"-2 28"deg])
	scatter!([X], [Y]; ms=10, msw=0, color=:cyan)
end

# ╔═╡ 8830d13c-04e7-4333-babc-10bb267993fe
@mdx """
And then just plot it!
"""

# ╔═╡ 8762e1a5-505b-4eed-8863-35171e8cc8e1
implot(img)

# ╔═╡ 50666f3e-b5a7-4fab-86a6-979c8da62693
@mdx """
!!! Question
	What was the reasoning for separating `plot` from `implot` again?
"""

# ╔═╡ 67e9e89e-7442-4d96-b8e2-fadb900a8cc3
@mdx """
In the background, AstroImages.jl calls the generic plotting package [Plots.jl](https://docs.juliaplots.org/stable/), and automatically adds a colorbar, tick marks, labels, and grid lines for us. The relevant transformations from pixel space to world coordinates (in this case RA and Dec) are also automatically applied based on the [WCS](https://www.atnf.csiro.au/people/mcalabre/WCS/) information stored in the image of our fits file.

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
By default, the origin is located in the bottom-left corner and indices increase to the right and up. Since `implot` returns a standard Plots.jl figure object, we can plot a test point on top of it [in the usual way](https://docs.juliaplots.org/latest/basics/):
"""

# ╔═╡ 12b9a88f-2f9a-4744-ba69-496545a0dac0
let
	p = implot(img; wcsticks=false, framestyle=:grid)
	scatter!(p, [500], [400]; ms=10, msw=0, color=:cyan)
end

# ╔═╡ e0a44c34-69f8-4037-82a8-60b196b87382
@mdx """
!!! Question
	`wcticks = false` seems to override `grid`. Is there a way to plot in pixel space while still having the grid lines enabled?
"""

# ╔═╡ aa60557e-faf0-4058-96fd-128ca093c773
@mdx """
We can go the other direction (from world cordinate space to pixel space) in the following two stages:

1. First, we use [AstroAngles.jl](https://github.com/JuliaAstro/AstroAngles.jl) to conveniently convert RA and Dec formatted input to their equivalent values in degrees for us. This package supports a wide range of formats, which are shown [here](https://github.com/JuliaAstro/AstroAngles.jl#usage). 
1. Next, we pass these values to the `world_to_pix` function exported by `AstroImages.jl` to make the WCS transformations in our final plot.

!!! Question
	Are degrees used internally for all cases?
"""

# ╔═╡ ba4e4e4e-7f0a-4590-981c-619b53fd0bec
let
	implot(img; wcsticks=true, framestyle=:grid)
	X, Y = world_to_pix(img, [hms"5 41 00"deg, dms"-2 28 00"deg])
	scatter!([X], [Y]; ms=10, msw=0, color=:cyan)
end

# ╔═╡ f62bae29-e31a-416e-b844-9720a5ef57f2
@mdx """
!!! Question
	Is it better to do `using AstroAngles` explicitly here?
"""

# ╔═╡ a6368cc9-b7c6-4ffd-a9ba-5ec33be3cb2b
@mdx """
Now that we have a way to plot a single arbitray point, let's extend this to a whole collection of known exoplanet coordinates.
"""

# ╔═╡ d03ffae4-5a15-448f-a47b-e850049efe80
@mdx """
## 🎯 Exoplanet locations

The [NASA Exoplanet Archive](https://exoplanetarchive.ipac.caltech.edu/) stores an updated list of known exoplanets, along with additional information about its host star and orbital parameters. As of this writing, there are 5,000+ confirmed detections, and fortunately their is an API to query all of this information!

The archive provides a Table Access Protocol [(TAP)](https://exoplanetarchive.ipac.caltech.edu/docs/TAP/usingTAP.html) service to query the data using an astronomy specific extension of SQL known as Astronomical Data Query Language [(ADQL)](https://www.ivoa.net/documents/ADQL/). This essentially boils down to pasting a query into a url, and then pulling it down with a `GET` request, which we accomplish with [HTTP.jl](https://juliaweb.github.io/HTTP.jl/stable/):
"""

# ╔═╡ 1319c8bf-ea90-469a-8433-5c3b66b1af07
q = """
select top 10 hostname, pl_name, tic_id
from pscomppars
"""

# ╔═╡ ef38432c-0ec4-46b7-9444-9321180729d9
query = "query=" * escapeuri(q) * "&format=csv"

# ╔═╡ 4d073b62-c25b-4cd9-be89-d87144f2bfdb
@mdx """
!!! note "Note"
	We use the `escapeuri` function exported by [URIs.jl](https://docs.juliahub.com/URIs/eec2u/1.3.0/#Tutorial) to convert the spaces and other special characters into valid [URI](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier) characters.
"""

# ╔═╡ 4581038a-fb53-49c7-a85f-60eb153b6f25
df = CSV.read(
	HTTP.get("https://exoplanetarchive.ipac.caltech.edu/TAP/sync"; query).body,
	DataFrame,
)

# ╔═╡ 403c435d-4d54-49d6-a50f-9f5362ae96d9
@mdx """
We now have the data in a convenient table format (provided by [DataFrames.jl](https://dataframes.juliadata.org/stable/)) for our queried exoplanets.
"""

# ╔═╡ 6db3d93a-0c35-4c27-ace7-1fb44966d864
@mdx """
### Data extraction

Whooo
"""

# ╔═╡ 127338cb-b917-4e2d-8ba1-3ed045c799a4
@mdx """
# Notebook setup 📦
"""

# ╔═╡ fcceea3e-db8f-4853-af49-240d66d54377
TableOfContents()

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
# ╟─50666f3e-b5a7-4fab-86a6-979c8da62693
# ╟─67e9e89e-7442-4d96-b8e2-fadb900a8cc3
# ╟─d4552736-159b-4c6a-9a97-ef57024333f7
# ╠═6fd6108a-dc97-42ed-a722-bc74c19a0bde
# ╟─b8e06c27-5504-41d1-b07c-c5259ff2681f
# ╠═12b9a88f-2f9a-4744-ba69-496545a0dac0
# ╟─e0a44c34-69f8-4037-82a8-60b196b87382
# ╟─aa60557e-faf0-4058-96fd-128ca093c773
# ╠═ba4e4e4e-7f0a-4590-981c-619b53fd0bec
# ╠═2d5365c9-c7d9-4d14-b074-f77b39baec02
# ╟─f62bae29-e31a-416e-b844-9720a5ef57f2
# ╟─a6368cc9-b7c6-4ffd-a9ba-5ec33be3cb2b
# ╟─d03ffae4-5a15-448f-a47b-e850049efe80
# ╠═cc2aaba1-4dfe-414f-8ace-71075e2f3bf5
# ╠═ad40234c-474c-489e-b328-73fa5ecfb6e2
# ╠═1319c8bf-ea90-469a-8433-5c3b66b1af07
# ╠═ef38432c-0ec4-46b7-9444-9321180729d9
# ╟─4d073b62-c25b-4cd9-be89-d87144f2bfdb
# ╠═4581038a-fb53-49c7-a85f-60eb153b6f25
# ╟─403c435d-4d54-49d6-a50f-9f5362ae96d9
# ╟─6db3d93a-0c35-4c27-ace7-1fb44966d864
# ╠═acdf51db-09e0-4e4c-b529-2db8030ea57c
# ╟─127338cb-b917-4e2d-8ba1-3ed045c799a4
# ╠═fcceea3e-db8f-4853-af49-240d66d54377
# ╠═f19b358c-8506-11ec-252c-c39dcd644d06
