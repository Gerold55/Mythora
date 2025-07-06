local biome_size = tonumber(minetest.settings:get("mythora_biome_size")) or 600  -- bigger biome size
local base_height = 64
local water_level = base_height

local biome_noise = PerlinNoise({
    offset = 0,
    scale = 1,
    spread = {x = biome_size, y = biome_size, z = biome_size},
    seed = 12345,
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

local function get_biome(x, z)
    local n = biome_noise:get_2d({x = x, y = z})
    if n < 0 then
        return "desert"
    else
        return "plains"
    end
end

local c_air = minetest.get_content_id("air")
local c_water = minetest.get_content_id("mapgen:water_source_plains")
local c_grass_plains = minetest.get_content_id("mapgen:grass_block_plains")
local c_sand = minetest.get_content_id("mapgen:sand")
local c_dirt = minetest.get_content_id("mapgen:dirt")
local c_stone = minetest.get_content_id("mapgen:stone")

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
                        data[vi] = (biome == "plains") and c_grass_plains or c_sand
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
