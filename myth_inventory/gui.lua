function myth_inventory.show_inventory(player)
    myth_inventory.ensure_inventory(player)
    local formspec = myth_inventory.get_formspec(player)
    minetest.show_formspec(player:get_player_name(), "myth_inventory:main", formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "myth_inventory:main" then return end
    -- Add logic here for buttons in future
end)
