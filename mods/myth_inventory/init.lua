-- myth_inventory/init.lua

local S = minetest.get_translator(minetest.get_current_modname())

myth_inventory = myth_inventory or {}

-- Creative inventory cache
creative_inventory = creative_inventory or {}
creative_inventory.registered_items = {}
creative_inventory.items = {}
creative_inventory.nodes = {}

minetest.register_on_mods_loaded(function()
    creative_inventory.registered_items = {}
    creative_inventory.items = {}
    creative_inventory.nodes = {}

    for name, def in pairs(minetest.registered_items) do
        if not (def.groups and def.groups.not_in_creative_inventory) then
            table.insert(creative_inventory.registered_items, name)
            if def.drawtype == "normal" or name:find("node") or name:find(":stone") then
                table.insert(creative_inventory.nodes, name)
            else
                table.insert(creative_inventory.items, name)
            end
        end
    end

    table.sort(creative_inventory.items)
    table.sort(creative_inventory.nodes)
end)

function myth_inventory.update_inventory_size(player)
    local inv = player:get_inventory()
    local bag_list = inv:get_list("bag") or {}
    local extra_slots = 0
    for _, item in ipairs(bag_list) do
        if not item:is_empty() then
            extra_slots = extra_slots + 9
        end
    end
    local total_slots = 27 + extra_slots
    inv:set_size("main", total_slots)
end

function myth_inventory.get_inventory_rows(player)
    local inv = player:get_inventory()
    local size = inv:get_size("main")
    return math.ceil(size / 9)
end

function myth_inventory.get_formspec(player, tab, subtab)
    tab = tab or "main"
    subtab = subtab or "items"
    local inv_rows = myth_inventory.get_inventory_rows(player)
    local inv_height = 3 + inv_rows * 0.6
    local is_creative = minetest.is_creative_enabled(player:get_player_name())

    local formspec =
        "size[16," .. inv_height .. "]" ..
        "background[0,0;16," .. inv_height .. ";myth_ui_bg.png]" ..
        -- Moved main tabs right from 0.5 to 1.5
        "tabheader[1,0;inventory_tabs;Inventory,Bags;" .. (tab == "bags" and 2 or 1) .. ";false;true]"

    if tab == "bags" then
        formspec = formspec ..
            "label[1.5,1.0;Your Bags]" .. -- shifted right from 0.5 to 1.5
            "list[current_player;bag;1.5,1.5;1,3;]" -- shifted right from 0.5 to 1.5
    else
        if is_creative then
            formspec = formspec ..
                -- Moved creative subtabs right from 1 to 2
                "tabheader[3.01,0;creative_subtabs;Items,Nodes;" .. (subtab == "nodes" and 2 or 1) .. ";false;true]"

            if subtab == "nodes" then
                formspec = formspec ..
                    "label[2,0.8;Creative Nodes]" ..  -- shifted right from 1.5 to 2
                    "list[current_player;creative;2,1.2;5,6;]" -- shifted right from 1 to 2
            else
                formspec = formspec ..
                    "label[2,0.8;Creative Items]" ..  -- shifted right
                    "list[current_player;creative;2,1.2;5,6;]" -- shifted right
            end

            formspec = formspec ..
                "label[8,0.8;Your Inventory]" ..  -- shifted right from 7 to 8
                "list[current_player;main;7.5,1.2;9," .. inv_rows .. ";]"  -- shifted right from 6.5 to 7.5
        else
            formspec = formspec ..
                "label[1.5,0.8;Your Inventory]" ..
                "list[current_player;main;1.5,1.2;9," .. inv_rows .. ";]" ..
                "label[1.5," .. (inv_rows + 1.5) .. ";Crafting]" ..
                "list[current_player;craft;1.5," .. (inv_rows + 2.0) .. ";2,2;]"
        end
    end

    formspec = formspec ..
        "listring[current_player;main]"

    if is_creative then
        formspec = formspec .. "listring[current_player;creative]"
    else
        formspec = formspec .. "listring[current_player;craft]"
    end

    return formspec
end

minetest.register_on_joinplayer(function(player)
    local inv = player:get_inventory()
    inv:set_size("main", 27)
    inv:set_size("craft", 4)
    inv:set_size("bag", 3)
    inv:set_size("creative", #creative_inventory.items)

    for i, item in ipairs(creative_inventory.items) do
        inv:set_stack("creative", i, ItemStack(item))
    end

    myth_inventory.update_inventory_size(player)

    local formspec = myth_inventory.get_formspec(player)
    player:set_inventory_formspec(formspec)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname:find("^myth_inventory:") or formname == "" then
        local tab_idx = tonumber(fields.inventory_tabs)
        local subtab_idx = tonumber(fields.creative_subtabs)
        local tab = (tab_idx == 2) and "bags" or "main"
        local subtab = (subtab_idx == 2) and "nodes" or "items"

        if tab == "main" and minetest.is_creative_enabled(player:get_player_name()) then
            local inv = player:get_inventory()
            local list = (subtab == "nodes") and creative_inventory.nodes or creative_inventory.items
            inv:set_size("creative", #list)
            for i, item in ipairs(list) do
                inv:set_stack("creative", i, ItemStack(item))
            end
        end

        local formspec = myth_inventory.get_formspec(player, tab, subtab)
        player:set_inventory_formspec(formspec)
        return true
    end

    if formname:match("^sfinv:") then
        local formspec = myth_inventory.get_formspec(player, "main")
        player:set_inventory_formspec(formspec)
        return true
    end
end)

minetest.register_chatcommand("inventory", {
    description = "Open custom inventory",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if player then
            player:set_inventory_formspec(myth_inventory.get_formspec(player))
        end
    end,
})

minetest.register_allow_player_inventory_action(function(player, action, inventory, info)
    if info and info.listname == "creative" then
        if action == "put" then return 0 end
    end
    return nil
end)

minetest.register_on_player_inventory_action(function(player, action, inventory, info)
    if info and info.listname == "creative" then
        local inv = player:get_inventory()
        local stack = inv:get_stack("creative", info.index)
        if stack:is_empty() then
            local name = creative_inventory.registered_items[info.index]
            if name then
                inv:set_stack("creative", info.index, ItemStack(name))
            end
        end
    end
end)
