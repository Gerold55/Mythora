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
