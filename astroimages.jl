### A Pluto.jl notebook ###
# v0.17.7

using Markdown
using InteractiveUtils

# ╔═╡ f19b358c-8506-11ec-252c-c39dcd644d06
begin
	import Pkg
	Pkg.activate(Base.current_project())
	
	using AstroImages, PlutoUI, Plots

	using CondaPkg
	CondaPkg.add.(("matplotlib", "astropy")); CondaPkg.resolve()
	using PythonCall
end

# ╔═╡ ab9977b9-3da3-473d-82ce-016fc0ced7a9
@py begin
	import matplotlib.pyplot as plt
	import astropy.io as apIO
	import astropy.wcs as apWCS
	import astropy.coordinates as apCoords
	import astropy.units as apU
end

# ╔═╡ 086a3ada-d74c-4662-9df5-21737ff06807
hdu = apIO.fits.open("m42_40min_red.fits")[0]

# ╔═╡ be69adc5-9553-421e-9a56-26899e00ff58
wcs = apWCS.WCS(hdu.header)

# ╔═╡ 51395c80-9946-4b08-96c1-c6e7ad53694d
coords = apCoords.SkyCoord("5h35m30s -5d20m00s")

# ╔═╡ 3ae1dd71-a557-4913-8b77-dae29d05dd12
img = hdu.data

# ╔═╡ 460f769a-8718-49ae-90b4-36282cd9cb32
begin
	fig = plt.figure()
	ax = fig.add_subplot(111, projection=wcs)
	
	ax.imshow(img, origin="lower")
	ax.scatter(coords.ra, coords.dec;
		color = "red",
		transform = ax.get_transform("world"),
	)
	#plt.grid(color="cyan")
	plt.gcf()
end

# ╔═╡ Cell order:
# ╠═f19b358c-8506-11ec-252c-c39dcd644d06
# ╠═ab9977b9-3da3-473d-82ce-016fc0ced7a9
# ╠═086a3ada-d74c-4662-9df5-21737ff06807
# ╠═be69adc5-9553-421e-9a56-26899e00ff58
# ╠═51395c80-9946-4b08-96c1-c6e7ad53694d
# ╠═3ae1dd71-a557-4913-8b77-dae29d05dd12
# ╠═460f769a-8718-49ae-90b4-36282cd9cb32
