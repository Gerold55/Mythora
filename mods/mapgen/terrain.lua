local mg_name = minetest.get_mapgen_setting("mg_name")

if mg_name == "singlenode" then

    local biome_size = tonumber(minetest.settings:get("mythora_biome_size")) or 600
    local base_height = 64
    local water_level = base_height

    local biome_noise = PerlinNoise({
        offset = 0,
        scale = 1,
        spread = {x = biome_size, y = biome_size, z = biome_size},
        seed = os.time(), -- ensure different world spawns
        octaves = 1,
        persist = 0.6,
    })

    local terrain_noise_plains = PerlinNoise({
        offset = 0,
        scale = 4,
        spread = {x = 150, y = 150, z = 150},
        seed = 54321,
        octaves = 2,
        persist = 0.5,
    })

    local terrain_noise_desert = PerlinNoise({
        offset = 0,
        scale = 3,
        spread = {x = 120, y = 120, z = 120},
        seed = 67890,
        octaves = 2,
        persist = 0.5,
    })

    local terrain_noise_fantasy = PerlinNoise({
        offset = 0,
        scale = 6,
        spread = {x = 100, y = 100, z = 100},
        seed = 98765,
        octaves = 3,
        persist = 0.6,
    })

    local function get_biome(x, z)
        local n = biome_noise:get_2d({x = x, y = z})
        if n < -0.33 then
            return "desert"
        elseif n < 0.33 then
            return "plains"
        else
            return "fantasy"
        end
    end

    local c_air = minetest.get_content_id("air")
    local c_water = minetest.get_content_id("mapgen:water_source_plains")
    local c_grass_plains = minetest.get_content_id("mapgen:grass_block_plains")
    local c_sand = minetest.get_content_id("mapgen:sand")
    local c_dirt = minetest.get_content_id("mapgen:dirt")
    local c_stone = minetest.get_content_id("mapgen:stone")
    local c_fantasy_soil = minetest.get_content_id("mapgen:grass_block_fantasy")

    minetest.register_on_generated(function(minp, maxp, seed)
        if maxp.y < 0 then return end

        local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
        local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
        local data = vm:get_data()

        for z = minp.z, maxp.z do
            for x = minp.x, maxp.x do
                local biome = get_biome(x, z)

                local height
                if biome == "plains" then
                    height = base_height + terrain_noise_plains:get_2d({x = x, y = z}) * 3
                elseif biome == "fantasy" then
                    height = base_height + terrain_noise_fantasy:get_2d({x = x, y = z}) * 6
                else
                    height = base_height + terrain_noise_desert:get_2d({x = x, y = z}) * 2
                end
                height = math.floor(height)

                for y = minp.y, maxp.y do
                    local vi = area:index(x, y, z)
                    if y > height then
                        if y <= water_level then
                            data[vi] = c_water
                        else
                            data[vi] = c_air
                        end
                    elseif y == height then
                        if y <= water_level then
                            data[vi] = c_sand
                        else
                            if biome == "plains" then
                                data[vi] = c_grass_plains
                            elseif biome == "fantasy" then
                                data[vi] = c_fantasy_soil
                            else
                                data[vi] = c_sand
                            end
                        end
                    elseif y >= height - 4 then
                        if y <= water_level then
                            data[vi] = c_sand
                        else
                            data[vi] = c_dirt
                        end
                    else
                        data[vi] = c_stone
                    end
                end
            end
        end

        vm:set_data(data)
        vm:calc_lighting()
        vm:update_liquids()
        vm:write_to_map()
    end)
end
