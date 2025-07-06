local tall_grass_biomes = {"plains", "swamp", "fantasy"}

for _, biome in ipairs(tall_grass_biomes) do
    local color = mapgen.biome_colors[biome]
    if not color then
        minetest.log("warning", "[mapgen] No color defined for biome: " .. biome)
        color = "#FFFFFF"  -- fallback color if missing
    end

    local bottom_name = "mapgen:tall_grass_bottom_" .. biome
    local top_name = "mapgen:tall_grass_top_" .. biome

    -- Bottom block
    minetest.register_node(bottom_name, {
        description = biome:gsub("^%l", string.upper) .. " Tall Grass (Bottom)",
        drawtype = "plantlike",
        tiles = {"myth_tall_grass_bottom.png^[colorize:" .. color .. ":150"},
        inventory_image = "myth_tall_grass_bottom.png",
        wield_image = "myth_tall_grass_bottom.png",
        walkable = false,
        sunlight_propagates = true,
        groups = {snappy = 3, flammable = 3, flora = 1, attached_node = 1},
        paramtype = "light",
        waving = 1,
        selection_box = {
            type = "fixed",
            fixed = {-0.15, -0.5, -0.15, 0.15, 0, 0.15},
        },

        on_construct = function(pos)
            local above = {x = pos.x, y = pos.y + 1, z = pos.z}
            local node_above = minetest.get_node_or_nil(above)
            if node_above and node_above.name == "air" then
                minetest.set_node(above, {name = top_name})
            end
        end,

        after_destruct = function(pos, oldnode)
            local above = {x = pos.x, y = pos.y + 1, z = pos.z}
            local n = minetest.get_node(above)
            if n and n.name == top_name then
                minetest.remove_node(above)
            end
        end,
    })

    -- Top block
    minetest.register_node(top_name, {
        description = biome:gsub("^%l", string.upper) .. " Tall Grass (Top)",
        drawtype = "plantlike",
        tiles = {"myth_tall_grass_top.png^[colorize:" .. color .. ":150"},
        walkable = false,
        sunlight_propagates = true,
        groups = {snappy = 3, flammable = 3, flora = 1, not_in_creative_inventory = 1},
        paramtype = "light",
        waving = 1,
        selection_box = {
            type = "fixed",
            fixed = {-0.15, 0, -0.15, 0.15, 0.5, 0.15},
        },
        drop = bottom_name,
    })

    -- Decoration registration
    minetest.register_decoration({
        name = "mapgen:tall_grass_" .. biome,
        deco_type = "simple",
        place_on = {"mapgen:grass_block_" .. biome},
        sidelen = 16,
        fill_ratio = 0.03,
        y_min = 1,
        y_max = 100,
        decoration = bottom_name,
        flags = "place_center_x,place_center_z",
    })
end

local biome = "plains"
local color_hex = mapgen.biome_colors[biome]

minetest.register_node("mapgen:small_grass_plains_1", {
    description = "Small Grass 1 (Plains)",
    drawtype = "plantlike",
    tiles = {"myth_grass1.png^[colorize:" .. color_hex .. ":150"},
    inventory_image = "myth_grass1.png",
    wield_image = "myth_grass1.png",
    walkable = false,
    sunlight_propagates = true,
    groups = {snappy=3, flammable=3, flora=1, attached_node=1, not_in_creative_inventory = 1},
    paramtype = "light",
    waving = 1,
    selection_box = {
        type = "fixed",
        fixed = {-0.15, -0.5, -0.15, 0.15, 0, 0.15},
    },
})

minetest.register_node("mapgen:small_grass_plains_2", {
    description = "Small Grass 2 (Plains)",
    drawtype = "plantlike",
    tiles = {"myth_grass2.png^[colorize:" .. color_hex .. ":150"},
    inventory_image = "myth_grass2.png",
    wield_image = "myth_grass2.png",
    walkable = false,
    sunlight_propagates = true,
    groups = {snappy=3, flammable=3, flora=1, attached_node=1, not_in_creative_inventory = 1},
    paramtype = "light",
    waving = 1,
    selection_box = {
        type = "fixed",
        fixed = {-0.15, -0.5, -0.15, 0.15, 0, 0.15},
    },
})

minetest.register_decoration({
    name = "mapgen:small_grass_plains_1",
    deco_type = "simple",
    place_on = {"mapgen:grass_block_plains"},
    sidelen = 16,
    fill_ratio = 0.05,
    y_min = 1,
    y_max = 100,
    decoration = "mapgen:small_grass_plains_1",
    flags = "place_center_x,place_center_z",
})

minetest.register_decoration({
    name = "mapgen:small_grass_plains_2",
    deco_type = "simple",
    place_on = {"mapgen:grass_block_plains"},
    sidelen = 16,
    fill_ratio = 0.05,
    y_min = 1,
    y_max = 100,
    decoration = "mapgen:small_grass_plains_2",
    flags = "place_center_x,place_center_z",
})
