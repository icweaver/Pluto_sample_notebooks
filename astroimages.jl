### A Pluto.jl notebook ###
# v0.19.4

using Markdown
using InteractiveUtils

# ╔═╡ f19b358c-8506-11ec-252c-c39dcd644d06
begin
	import Pkg
	Pkg.activate(Base.current_project())
	
	using AstroImages, PlutoUI, Plots, ImageIO
end

# ╔═╡ 59584fac-598d-4752-82fa-840378d70c08
Pkg.status()

# ╔═╡ bb2425be-3e6a-456d-bad2-e665dc7408aa
fname = download("http://data.astropy.org/tutorials/FITS-images/HorseHead.fits")

# ╔═╡ a5d80eed-fb12-4980-82db-800a1c4dba49
h = load(fname)

# ╔═╡ Cell order:
# ╠═f19b358c-8506-11ec-252c-c39dcd644d06
# ╠═59584fac-598d-4752-82fa-840378d70c08
# ╠═bb2425be-3e6a-456d-bad2-e665dc7408aa
# ╠═a5d80eed-fb12-4980-82db-800a1c4dba49
