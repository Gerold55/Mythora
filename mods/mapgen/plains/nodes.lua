local biome_colors = mapgen.biome_colors
local water_colors = mapgen.water_colors

local function register_biome_grass(name)
    local color_hex = biome_colors[name]
    if not color_hex then
        minetest.log("warning", "[mapgen] No color defined for biome: " .. name)
        return
    end

    minetest.register_node("mapgen:grass_block_" .. name, {
        description = "Grass Block (" .. name:gsub("^%l", string.upper) .. ")",
        tiles = {
            -- Top: base grass texture colorized
            "myth_grass_top.png^[colorize:" .. color_hex .. ":150",

            -- Bottom: plain dirt
            "myth_dirt.png",

            -- Side: dirt + grass overlay (only grass is colorized)
            {
                name = "myth_dirt.png^(myth_grass_side.png^[colorize:" .. color_hex .. ":150)",
                backface_culling = false,
            }
        },
        groups = {crumbly = 3, soil = 1},
        drop = "mapgen:dirt",
        sunlight_propagates = true,
        paramtype = "light",
        is_ground_content = true,

        on_place = function(itemstack, placer, pointed_thing)
            local pos = pointed_thing.above
            if not pos then return itemstack end

            -- Get biome id and biome name at the placed position
            local biome_id = minetest.get_biome_data(pos).biome
            local biome_name = minetest.get_biome_name(biome_id)

            -- Compose the biome grass node name
            local biome_node_name = "mapgen:grass_block_" .. biome_name

            -- Check if node is registered for that biome and place it instead
            if minetest.registered_nodes[biome_node_name] then
                minetest.set_node(pos, {name = biome_node_name})
                if not minetest.is_creative_enabled(placer:get_player_name()) then
                    itemstack:take_item()
                end
                return itemstack
            end

            -- Fallback: place plains grass block normally
            minetest.set_node(pos, {name = "mapgen:grass_block_plains"})
            if not minetest.is_creative_enabled(placer:get_player_name()) then
                itemstack:take_item()
            end
            return itemstack
        end,
    })
end

for biome_name, _ in pairs(biome_colors) do
    register_biome_grass(biome_name)
end


-- Dirt block (shared across all biomes)
minetest.register_node("mapgen:dirt", {
    description = "Dirt Block",
    tiles = {"myth_dirt.png"},
    groups = {crumbly = 3, soil = 1},
})

minetest.register_node("mapgen:stone", {
    description = "Stone",
    tiles = {"myth_stone.png"},
    groups = {cracky = 3, stone = 1},
})

minetest.register_node("mapgen:sand", {
    description = "Sand",
    tiles = {"myth_sand.png"},
    groups = {crumbly = 3, falling_node = 1, sand = 1},
    is_ground_content = true
})

local function register_biome_water(name, color_hex)

    minetest.register_node("mapgen:water_source_" .. name, {
        description = name:gsub("^%l", string.upper) .. " Water Source",
        drawtype = "liquid",
        tiles = {
            {
                name = "myth_water_source_animated.png",
                color = color_hex,
                animation = {
                    type = "vertical_frames",
                    aspect_w = 16,
                    aspect_h = 16,
                    length = 2.0,
                },
            },
        },
        special_tiles = {
            {
                name = "myth_water_source_animated.png",
                color = color_hex,
                animation = {
                    type = "vertical_frames",
                    aspect_w = 16,
                    aspect_h = 16,
                    length = 2.0,
                },
            },
            {
                name = "myth_water_source_animated.png",
                color = color_hex,
                animation = {
                    type = "vertical_frames",
                    aspect_w = 16,
                    aspect_h = 16,
                    length = 2.0,
                },
            },
        },
		use_texture_alpha = "blend",
		paramtype = "light",
        liquidtype = "source",
        liquid_alternative_flowing = "mapgen:water_flowing_" .. name,
        liquid_alternative_source = "mapgen:water_source_" .. name,
        liquid_viscosity = 1,
        liquid_renewable = false,
		walkable = false,
        damage_per_second = 0,
        groups = {water = 3, liquid = 3, puts_out_fire = 1, cools_lava = 1},
        post_effect_color = {
            a = 103,
            r = tonumber("0x" .. color_hex:sub(2,3),16),
            g = tonumber("0x" .. color_hex:sub(4,5),16),
            b = tonumber("0x" .. color_hex:sub(6,7),16),
        },
        sounds = default and default.node_sound_water_defaults or nil,
    })

    minetest.register_node("mapgen:water_flowing_" .. name, {
        description = name:gsub("^%l", string.upper) .. " Water (Flowing)",
        drawtype = "flowingliquid",
        tiles = {"myth_water_flowing_animated.png^[colorize:" .. color_hex .. ":70"},
        special_tiles = {
            {
                name = "myth_water_flowing_animated.png",
                color = color_hex,
                animation = {
                    type = "vertical_frames",
                    aspect_w = 16,
                    aspect_h = 16,
                    length = 0.8,
                },
            },
        },
		use_texture_alpha = "blend",
		paramtype = "light",
        liquidtype = "flowing",
        liquid_alternative_flowing = "mapgen:water_flowing_" .. name,
        liquid_alternative_source = "mapgen:water_source_" .. name,
        liquid_viscosity = 1,
        liquid_renewable = false,
        damage_per_second = 0,
		walkable = false,
        groups = {water = 3, liquid = 3, puts_out_fire = 1, cools_lava = 1, not_in_creative_inventory = 1},
        post_effect_color = {
            a = 103,
            r = tonumber("0x" .. color_hex:sub(2,3),16),
            g = tonumber("0x" .. color_hex:sub(4,5),16),
            b = tonumber("0x" .. color_hex:sub(6,7),16),
        },
        sounds = default and default.node_sound_water_defaults or nil,
    })
end

-- Example usage:
register_biome_water("plains", "#7ABCFF")

