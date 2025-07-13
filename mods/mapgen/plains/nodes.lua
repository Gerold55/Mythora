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

minetest.register_node("mapgen:brick", {
    description = "Brick",
    tiles = {"myth_brick.png"},
    groups = {cracky = 3, stone = 1},
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

local texture_variants = {
    uv0   = "",
    uv90  = "^[transformR90",
    uv180 = "^[transformR180",
    uv270 = "^[transformR270",
}

local base_texture = "myth_leaves_oak1.png"

local function register_oak_leaves_for_biome(biome_name)
    local color_hex = biome_colors[biome_name]
    if not color_hex then
        minetest.log("warning", "[mapgen] No color defined for biome leaves: " .. biome_name)
        return
    end

    for variant, transform in pairs(texture_variants) do
        local node_name = "mapgen:leaves_" .. biome_name .. "_oak_" .. variant

        -- Define groups, hiding all but uv0 from inventory
        local groups = {
            snappy = 3,
            flammable = 2,
            leaves = 1
        }

        if variant ~= "uv0" then
            groups.not_in_creative_inventory = 1
        end

        minetest.register_node(node_name, {
            description = biome_name:gsub("^%l", string.upper) .. " Oak Leaves",
            drawtype = "mesh",
            mesh = "myth_oak_leaves.obj",
            tiles = {
                base_texture .. transform .. "^[colorize:" .. color_hex .. ":150"
            },
            paramtype = "light",
            use_texture_alpha = "clip",
            waving = 1,
            sunlight_propagates = true,
            walkable = false,
            groups = groups,
            selection_box = {
                type = "fixed",
                fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
            },
            drop = "mapgen:leaves_" .. biome_name .. "_oak_uv0",
        })
    end
end

-- Register oak leaves for all defined biomes
for biome_name, _ in pairs(biome_colors) do
    register_oak_leaves_for_biome(biome_name)
end

local function can_grow_tree(pos)
    -- Check if there’s enough space for the tree to grow
    -- Customize bounds depending on your tree generator's size

    for x = -3, 3 do
        for y = 1, 6 do
            for z = -3, 3 do
                local p = {x=pos.x + x, y=pos.y + y, z=pos.z + z}
                local node = minetest.get_node(p)
                if node.name ~= "air" and node.name ~= "ignore" then
                    return false
                end
            end
        end
    end
    return true
end

local function place_sapling(itemstack, placer, pointed_thing)
    if not pointed_thing or pointed_thing.type ~= "node" then
        return itemstack
    end

    local under = pointed_thing.under
    local above = pointed_thing.above
    local node_under = minetest.get_node(under)

    -- You may want to restrict sapling placement to grass or dirt
    local allowed_soil = {
        ["mapgen:grass_block_greenhollow"] = true,
        ["mapgen:dirt"] = true,
    }

    if not allowed_soil[node_under.name] then
        return itemstack -- disallow placement on non-soil nodes
    end

    -- Check if above node is air
    local node_above = minetest.get_node(above)
    if node_above.name ~= "air" then
        return itemstack -- can't place if no space above
    end

    -- Place sapling
    minetest.set_node(above, {name = "mapgen:sapling_oak"})

    if not minetest.is_creative_enabled(placer:get_player_name()) then
        itemstack:take_item()
    end

    return itemstack
end

minetest.register_node("mapgen:sapling_oak", {
    description = "Oak Tree Sapling",
    drawtype = "plantlike",
    tiles = {"myth_sapling_oak.png"},
    inventory_image = "myth_sapling_oak.png",
    wield_image = "myth_sapling_oak.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    selection_box = {
        type = "fixed",
        fixed = {-4/16, -0.5, -4/16, 4/16, 7/16, 4/16},
    },
    groups = {snappy = 2, dig_immediate = 3, flammable = 2, attached_node = 1, sapling = 1},

    on_timer = function(pos)
        if can_grow_tree(pos) then
            grow_mythora_oak_tree(pos)
        else
            -- Not enough space yet, restart timer to try later
            minetest.get_node_timer(pos):start(600)
        end
    end,

    on_construct = function(pos)
        minetest.get_node_timer(pos):start(math.random(300, 1500))
    end,

    on_place = place_sapling,
})


 minetest.register_node("mapgen:tree_oak", {
        description = "Oak Log",
        tiles = {
            "myth_oak_top.png",
            "myth_oak_top.png",
            "myth_oak_side.png",
        },
        paramtype2 = "facedir",
        is_ground_content = false,
        groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
        on_place = minetest.rotate_node,
    })

minetest.register_node("mapgen:wood_planks", {
    description = "Oak Wood Planks",
    tiles = {"myth_oak_wood.png"},
    paramtype2 = "facedir",
    place_param2 = 0,
    is_ground_content = false,
    groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
})



-- Example usage:
register_biome_water("plains", "#7ABCFF")

