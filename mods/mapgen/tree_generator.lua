-- tree_generator.lua

local leaf_variants = {"uv0", "uv90", "uv180", "uv270"}

local function place_leaf(pos)
    local suffix = leaf_variants[math.random(#leaf_variants)]
    minetest.set_node(pos, {name = "mapgen:leaves_" .. suffix})
end

local function place_log(pos)
    minetest.set_node(pos, {name = "mapgen:log"})
end

local function generate_tree(pos)
    -- Trunk
    for y = 0, 4 do
        place_log({x = pos.x, y = pos.y + y, z = pos.z})
    end

    local top_y = pos.y + 4

    -- Leaf cluster
    for dx = -2, 2 do
        for dy = -1, 2 do
            for dz = -2, 2 do
                local d = math.abs(dx) + math.abs(dy) + math.abs(dz)
                if d < 4 and math.random() < 0.85 then
                    local leaf_pos = {
                        x = pos.x + dx,
                        y = top_y + dy,
                        z = pos.z + dz
                    }
                    place_leaf(leaf_pos)
                end
            end
        end
    end
end

-- Tree decoration
minetest.register_decoration({
    name = "mapgen:greenhollow_tree",
    deco_type = "schematic",
    place_on = {"mapgen:grass_block_greenhollow"},
    sidelen = 16,
    fill_ratio = 0.005,
    y_min = 1,
    y_max = 100,
    flags = "place_center_x,place_center_z",
    schematic = {
        size = {x = 1, y = 1, z = 1},
        data = {{{name = "air"}}}, -- dummy placeholder
    },
    on_place = function(pos)
        generate_tree(pos)
    end,
})

function grow_mythora_oak_tree(pos)
    -- Here you place your trunk and leaves, possibly using voxelmanip as before
    -- For example, replace the node above with a trunk_rot randomly:

    local trunk_node = trunk_nodes[math.random(#trunk_nodes)]

    local above = {x = pos.x, y = pos.y + 1, z = pos.z}
    minetest.set_node(above, {name = trunk_node})

    -- Then build trunk upwards and add leaves - you can reuse your existing place_tree function or adapt it here

    -- This is a simple placeholder
    minetest.chat_send_all("Growing Mythora Oak Tree at " .. minetest.pos_to_string(pos))
end
