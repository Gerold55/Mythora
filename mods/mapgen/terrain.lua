-- Register aliases for your mapgen nodes
minetest.register_alias("mapgen_stone", "mapgen:stone")
minetest.register_alias("mapgen_water_source", "mapgen:water_source_plains")
minetest.register_alias("mapgen_river_water_source", "mapgen:water_source_plains")

-- GreenHollow Plains biome
minetest.register_biome({
    name = "greenhollow",
    node_top = "mapgen:grass_block_plains",
    depth_top = 1,
    node_filler = "mapgen:dirt",
    depth_filler = 3,
    y_max = 31000,
    y_min = 6,
    heat_point = 50,
    humidity_point = 50,
})

minetest.register_biome({
    name = "greenhollow_ocean",
    node_top = "mapgen:sand",
    depth_top = 1,
    node_filler = "mapgen:sand",
    depth_filler = 3,
    node_cave_liquid = "mapgen:water_source_plains",
    y_max = 5,
    y_min = -255,
    heat_point = 50,
    humidity_point = 50,
})

minetest.register_biome({
    name = "greenhollow_underground",
    node_cave_liquid = "mapgen:water_source_plains",
    y_max = -256,
    y_min = -31000,
    heat_point = 50,
    humidity_point = 50,
})

-- Lunaria Wilds biome
minetest.register_biome({
    name = "lunaria_wilds",
    node_top = "mapgen:grass_block_fantasy",
    depth_top = 1,
    node_filler = "mapgen:dirt",
    depth_filler = 3,
    y_max = 31000,
    y_min = 6,
    heat_point = 45,
    humidity_point = 65,
})

minetest.register_biome({
    name = "lunaria_ocean",
    node_top = "mapgen:sand",
    depth_top = 1,
    node_filler = "mapgen:sand",
    depth_filler = 3,
    node_cave_liquid = "mapgen:water_source_plains",
    y_max = 5,
    y_min = -255,
    heat_point = 45,
    humidity_point = 65,
})

minetest.register_biome({
    name = "lunaria_underground",
    node_cave_liquid = "mapgen:water_source_plains",
    y_max = -256,
    y_min = -31000,
    heat_point = 45,
    humidity_point = 65,
})

minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_grass = minetest.get_content_id("mapgen:grass_block_plains")
    local c_mossgrass = minetest.get_content_id("mapgen:mossgrass")
    local c_air = minetest.get_content_id("air")

    -- 2D Perlin noise for patches
    local perlin = minetest.get_perlin({
        offset = 0,
        scale = 1,
        spread = {x = 100, y = 100, z = 100},
        seed = seed + 6789,
        octaves = 3,
        persist = 0.6
    })

    for z = minp.z, maxp.z do
        for x = minp.x, maxp.x do
            local noise_val = perlin:get_2d({x = x, y = z})
            if noise_val > 0.5 then  -- Only apply mossgrass in "patch zones"
                for y = maxp.y, minp.y, -1 do
                    local vi = area:index(x, y, z)
                    local vi_above = area:index(x, y + 1, z)
                    if data[vi] == c_grass and data[vi_above] == c_air then
                        data[vi] = c_mossgrass
                        break
                    end
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
    vm:update_map()
end)
