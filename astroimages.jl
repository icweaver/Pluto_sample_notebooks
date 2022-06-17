### A Pluto.jl notebook ###
# v0.19.9

#> [frontmatter]
#> title = "ExoFinder.jl"
#> description = "Let's find some worlds!"

using Markdown
using InteractiveUtils

# ╔═╡ f19b358c-8506-11ec-252c-c39dcd644d06
begin
	import Pkg
	Pkg.activate(Base.current_project())
	
	using AstroImages, CSV, DataFramesMeta, PlutoUI
	using MarkdownLiteral: @mdx
	using AlgebraOfGraphics: set_aog_theme!
	
	import CairoMakie as Mk

	set_aog_theme!()

	TableOfContents()
end

# ╔═╡ cc2aaba1-4dfe-414f-8ace-71075e2f3bf5
using HTTP

# ╔═╡ ad40234c-474c-489e-b328-73fa5ecfb6e2
using HTTP.URIs

# ╔═╡ 2c399bbc-c320-4995-a9cd-b293107da69e
using AstroImages: WCSTransform

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

# ╔═╡ d03ffae4-5a15-448f-a47b-e850049efe80
@mdx """
## Exoplanet locations 🎯

The [NASA Exoplanet Archive](https://exoplanetarchive.ipac.caltech.edu/) stores an updated list of known exoplanets, along with additional information about its host star and orbital parameters. As of this writing, there are 5,000+ confirmed detections, and fortunately their is an API to query all of this information!

The archive provides a Table Access Protocol [(TAP)](https://exoplanetarchive.ipac.caltech.edu/docs/TAP/usingTAP.html) service to query the data using an astronomy specific extension of SQL known as Astronomical Data Query Language [(ADQL)](https://www.ivoa.net/documents/ADQL/). This essentially boils down to pasting a query into a url, and then pulling it down with a `GET` request, which we accomplish with [HTTP.jl](https://juliaweb.github.io/HTTP.jl/stable/):
"""

# ╔═╡ 1319c8bf-ea90-469a-8433-5c3b66b1af07
q = """
select top 500 hostname, pl_name, tic_id, ra, dec, sy_vmag
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
df_exoplanets = CSV.read(
	HTTP.get("https://exoplanetarchive.ipac.caltech.edu/TAP/sync"; query).body,
	DataFrame,
)

# ╔═╡ 58dabe30-7322-4a49-93e5-51f9a921ed0c
# @chain df_exoplanets begin
# 	# @aside begin
# 	# 	C = Matrix(_[:, [:ra, :dec]])'
# 	# 	ra_x, ra_y = eachcol(world_to_pix(img, C)')
# 	# end
# 	# @transform begin
# 	# 	:ra_px = ra_x
# 	# 	:dec_px = ra_y
# 	# end
# end

# ╔═╡ 403c435d-4d54-49d6-a50f-9f5362ae96d9
@mdx """
We now have the data in a convenient table format (provided by [DataFrames.jl](https://dataframes.juliadata.org/stable/)) for our queried exoplanets.
"""

# ╔═╡ 36b9289f-7b61-464f-9faf-51c821d2d455
md"""
## Bright stars ⭐

Now that we have the locations of known exoplanets, let's next collect the locations of known bright stars in the night sky that form some well known constellations. We will use the [HYG](http://www.astronexus.com/hyg) database of stars to collect these targets.
"""

# ╔═╡ 767a2fd0-ec0f-410c-8069-7530bacd5f75
df_hyg = let
	f = download("https://raw.githubusercontent.com/astronexus/HYG-Database/master/hygdata_v3.csv")
	df = CSV.read(f, DataFrame)
	# dropmissing(df, [:bayer, :bf])
	dropmissing(df, :hip)
end

# ╔═╡ 107fac15-cd49-43bf-9b70-d67c5e09461d
md"""
## Constellations △

We will next cross reference this list of known bright stars with the stars that make-up some well known constellations, which we can download from [Stellarium](https://github.com/Stellarium/stellarium/tree/master/skycultures) to plot their shapes.

!!! note
	Inspired from: <https://github.com/eleanorlutz/western_constellations_atlas_of_space>
"""

# ╔═╡ 0512833c-38d6-4840-bd34-3820c24070ff
function parse_line(s)
	tokens = split(s)
	return (
		name = tokens[begin],
		npairs = parse(Int, tokens[begin+1]),
		ids = parse.(Int, tokens[begin+2:end])
	)
end

# ╔═╡ 79a281b3-50d8-4b8d-ad00-200b311bcd89
function ra_dec_coord(id, df)
	tmp = df[df.hip .== id, [:ra, :dec]]
	return (360/24) * tmp[1, 1], tmp[1, 2]
end

# ╔═╡ 8eb12793-ba01-4a93-a132-4ca2ccd9ba3e
df_constellations = let
	f = download("https://raw.githubusercontent.com/Stellarium/stellarium/master/skycultures/western/constellationship.fab")
	df = DataFrame()
	for line ∈ readlines(f; keep=true)
		!isletter(line[1]) && continue
		row = parse_line(line)
		push!(df, row)
	end

	@rtransform! df :ra_dec = ra_dec_coord.(:ids, Ref(df_hyg))
	
	df
end

# ╔═╡ 44f11ff7-c3cf-4cdf-8863-37efe883a227
wcs_img = WCSTransform(2;
	cdelt = [-2/30, 2/30],
	ctype = ["RA---AZP", "DEC--AZP"],
	crpix = [-254.1100848779, -11.34948542534],
	crval = [0., -90.0],
	pv    = [(2, 1, 45.0)],
)

# ╔═╡ 4b950742-6089-43e8-9cbc-8a2c7b3313e2
world_to_pixp(wcs, p) = world_to_pix(wcs, [p[1], p[2]])

# ╔═╡ 364ee60e-60a8-4cb5-b462-5080dd8d9b55
begin
	L = 4_000
	fig = Mk.Figure(resolution=(1200, 700))
	ax = Mk.Axis(fig[1, 1];
		xticks = 0:45:360,
		yticks = -90:30:90,
		xlabel = "RA (degrees)",
		ylabel = "Dec (degrees)",
		# xreversed = true,
		# limits = (-L, L, -L, L),
		title = "Cartesian projection",
	)

	ax_transform = Mk.Axis(fig[1, 2]; title="Zenithal projection")
	Mk.hidedecorations!(ax_transform)
	
	# Constellations
	for row ∈ eachrow(df_constellations)
		coords = row[:ra_dec]
		Mk.linesegments!(ax, coords)
		coords_transform = Tuple.(world_to_pixp.(Ref(wcs_img), coords))
		Mk.linesegments!(ax_transform, coords_transform)
	end

	# Exoplanets
	Mk.scatter!(ax, df_exoplanets.ra, df_exoplanets.dec;
		color = (:darkgrey, 0.5)
	)

	fig |> as_svg
end

# ╔═╡ 8be56c46-6b15-470d-8ac7-0a94c8946211
fig

# ╔═╡ 27bb7d33-f377-455c-a46f-0c0f99b35e98
@mdx """
!!! todo
	1. Make interactive with [PlutoPlotly](https://github.com/JuliaPluto/PlutoPlotly.jl)

	2. Use FITS file for background image and automatic coordinate-aware plots

	2. Experiment with different [coordinate transforms](https://www.atnf.csiro.au/people/mcalabre/WCS/example_data.html), e.g.:

		```julia
		using AstroImages: WCSTransform
	
		wcs = WCSTransform(2;
			cdelt = [-0.066667, 0.066667],
			ctype = ["RA---CAR", "DEC--CAR"],
			crpix = [-248.2173814412, 7.527038199745],
			crval = [0., -90],
		)
	
		# Or
		# using AstroImages
		# img = AstroImage("path/to/fits/file")
		# wcs = AstroImages.wcsfromheader(img)[1]
	
		world_to_pixp(wcs, p) = world_to_pix(wcs, [p[1], p[2]])
	
		coords_transform = Tuple.(world_to_pixp.(Ref(wcs), coords))
		Mk.linesegments!(ax, coords_transform)
		```

"""

# ╔═╡ 127338cb-b917-4e2d-8ba1-3ed045c799a4
@mdx """
# Notebook setup 📦
"""

# ╔═╡ Cell order:
# ╟─3845b39a-a637-4d2b-b2b9-f4ac0294f0e9
# ╟─8be56c46-6b15-470d-8ac7-0a94c8946211
# ╟─e58691c1-98ed-4e75-a5bb-e03102e62def
# ╟─3ea72aeb-356c-4fd1-b228-f0cf0cba2df7
# ╟─d03ffae4-5a15-448f-a47b-e850049efe80
# ╠═cc2aaba1-4dfe-414f-8ace-71075e2f3bf5
# ╠═ad40234c-474c-489e-b328-73fa5ecfb6e2
# ╠═1319c8bf-ea90-469a-8433-5c3b66b1af07
# ╠═ef38432c-0ec4-46b7-9444-9321180729d9
# ╟─4d073b62-c25b-4cd9-be89-d87144f2bfdb
# ╠═4581038a-fb53-49c7-a85f-60eb153b6f25
# ╠═58dabe30-7322-4a49-93e5-51f9a921ed0c
# ╟─403c435d-4d54-49d6-a50f-9f5362ae96d9
# ╟─36b9289f-7b61-464f-9faf-51c821d2d455
# ╠═767a2fd0-ec0f-410c-8069-7530bacd5f75
# ╟─107fac15-cd49-43bf-9b70-d67c5e09461d
# ╠═8eb12793-ba01-4a93-a132-4ca2ccd9ba3e
# ╟─0512833c-38d6-4840-bd34-3820c24070ff
# ╟─79a281b3-50d8-4b8d-ad00-200b311bcd89
# ╠═364ee60e-60a8-4cb5-b462-5080dd8d9b55
# ╠═2c399bbc-c320-4995-a9cd-b293107da69e
# ╠═44f11ff7-c3cf-4cdf-8863-37efe883a227
# ╠═4b950742-6089-43e8-9cbc-8a2c7b3313e2
# ╟─27bb7d33-f377-455c-a46f-0c0f99b35e98
# ╟─127338cb-b917-4e2d-8ba1-3ed045c799a4
# ╠═f19b358c-8506-11ec-252c-c39dcd644d06
