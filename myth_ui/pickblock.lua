minetest.register_chatcommand("pickblock", {
    description = "Pick the node you are looking at and add it to your inventory",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Player not found." end

        local eye_pos = vector.add(player:get_pos(), {x=0, y=1.625, z=0})
        local dir = player:get_look_dir()
        local ray_len = 10
        local pointed_pos = vector.add(eye_pos, vector.multiply(dir, ray_len))

        local ray = minetest.raycast(eye_pos, pointed_pos, false, false)
        for pointed in ray do
            if pointed.type == "node" then
                local node = minetest.get_node(pointed.under)
                if node and node.name ~= "air" then
                    local inv = player:get_inventory()
                    local stack = ItemStack(node.name)
                    if inv:room_for_item("main", stack) then
                        inv:add_item("main", stack)
                        return true, "Picked: " .. node.name
                    else
                        return false, "No room in inventory"
                    end
                end
            end
        end

        return false, "No node in sight"
    end,
})
