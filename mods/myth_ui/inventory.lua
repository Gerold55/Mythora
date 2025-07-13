-- myth_ui/inventory.lua

-- Register the custom inventory page
sfinv.register_page("myth_ui:main", {
    title = "Inventory",
    get = function(self, player, context)
        return sfinv.make_formspec(player, context, [[
            label[0,0;Welcome to Mythora!]
            list[current_player;main;0.5,1;8,4;]
            listring[current_player;main]
        ]], true)
    end
})

-- Force our inventory as the default one
minetest.register_on_joinplayer(function(player)
    minetest.after(0.1, function()
        if sfinv and sfinv.set_page then
            sfinv.set_page(player, "myth_ui:main")
        end
    end)
end)

minetest.register_on_player_inventory_action(function(player, action, inventory, info)
    if action == "take" and inventory:get_name() == "creative" then
        local wielded_stack = player:get_wielded_item()
        local item_name = wielded_stack:get_name()
        if item_name ~= "" then
            local full_stack = ItemStack(item_name .. " 99")  -- 99 is max stack size in creative
            player:set_wielded_item(full_stack)
        end
    end
end)
