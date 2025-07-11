local tall_grass_biomes = {"plains", "swamp", "fantasy"}

-- Biome colors for tinting tall grass textures
mapgen = mapgen or {}
mapgen.biome_colors = {
    plains = "#2C4900",
    swamp = "#567d4a",
    fantasy = "#a450ff",
}

-- Small grass decorations for plains biome
mapgen.biome_colors.plains = "#2C4900"
local color_hex = mapgen.biome_colors.plains

for i = 1, 2 do
    local name = "mapgen:small_grass_plains_" .. i
    local texture = "myth_grass" .. i .. ".png"

    minetest.register_node(name, {
        description = "Small Grass " .. i .. " (Plains)",
        drawtype = "plantlike",
        tiles = {texture .. "^[colorize:" .. color_hex .. ":150"},
        inventory_image = texture,
        wield_image = texture,
        walkable = false,
        sunlight_propagates = true,
        groups = {snappy = 3, flammable = 3, flora = 1, attached_node = 1, not_in_creative_inventory = 1},
        paramtype = "light",
        waving = 1,
        selection_box = {
            type = "fixed",
            fixed = {-0.15, -0.5, -0.15, 0.15, 0, 0.15},
        },
    })

    minetest.register_decoration({
        name = name,
        deco_type = "simple",
        place_on = {"mapgen:grass_block_plains"},
        sidelen = 16,
        fill_ratio = 0.05,
        y_min = 2,
        y_max = 100,
        decoration = name,
        flags = "place_center_x,place_center_z",
    })
end
