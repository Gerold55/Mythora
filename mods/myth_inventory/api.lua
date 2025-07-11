function myth_inventory.get_inv(player)
    return minetest.get_inventory({type = "player", name = player:get_player_name()})
end

function myth_inventory.ensure_inventory(player)
    local inv = player:get_inventory()
    if not inv:get_size("main") then
        inv:set_size("main", 40)  -- 4x10
    end
    if not inv:get_size("armor") then
        inv:set_size("armor", 4)
    end
end
