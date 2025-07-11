mapgen = {}  -- Global mod namespace if not using one already

mapgen.biome_colors = {
    plains  = "#2C4900",  -- lush green
    dry     = "#A09060",  -- dry yellow
    swamp   = "#507050",  -- dark green
    snowy   = "#B0E0E6",  -- icy blue
    fantasy = "#AA55FF",  -- purple
	ocean   = "#4F81C7",
}

water_colors = {
    plains = "#7ABCFF",
    swamp = "#3C5D3D",
    ocean = "#1E3F66"
}

-- Get the current mod's path dynamically
local modpath = minetest.get_modpath(minetest.get_current_modname())

-- Load biome-specific files (Goldenreach Plains)
dofile(modpath .. "/plains/nodes.lua")
dofile(modpath .. "/plains/decorations.lua")

-- Load terrain generator first
dofile(modpath .. "/terrain.lua")

minetest.register_biome({
    name = "goldenreach_plains",
    node_top = "mapgen:plains_grass",
    depth_top = 1,
    node_filler = "mapgen:plains_dirt",
    depth_filler = 3,
    y_max = 80,
    y_min = 1,
    heat_point = 50,
    humidity_point = 40,
})
