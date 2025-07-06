-- myth_inventory/init.lua

local S = minetest.get_translator(minetest.get_current_modname())
local modpath = minetest.get_modpath(minetest.get_current_modname())

-- Provide mod namespace
myth_inventory = myth_inventory or {}

-- Initialize creative inventory for creative mode
creative_inventory = creative_inventory or {}
creative_inventory.registered_items = {}

-- Register all items to creative inventory (except those marked not_in_creative_inventory)
minetest.register_on_mods_loaded(function()
    creative_inventory.registered_items = {}
    for name, def in pairs(minetest.registered_items) do
        if not (def.groups and def.groups.not_in_creative_inventory) then
            table.insert(creative_inventory.registered_items, name)
        end
    end
    table.sort(creative_inventory.registered_items)
end)

-- Update inventory size based on bags placed
function myth_inventory.update_inventory_size(player)
    local inv = player:get_inventory()
    local bag_list = inv:get_list("bag") or {}
    local extra_slots = 0
    for _, item in ipairs(bag_list) do
        if not item:is_empty() then
            extra_slots = extra_slots + 9 -- each bag adds 1 row (9 slots)
        end
    end
    local total_slots = 27 + extra_slots -- base 3x9 + extras from bags
    inv:set_size("main", total_slots)
end

-- Show player inventory formspec
function myth_inventory.show_formspec(player, tab)
    local name = player:get_player_name()
    tab = tab or "main"
    minetest.show_formspec(name, "myth_inventory:" .. tab, myth_inventory.get_formspec(player, tab))
end

-- Get how many inventory rows to show
function myth_inventory.get_inventory_rows(player)
    local inv = player:get_inventory()
    local size = inv:get_size("main")
    return math.ceil(size / 9)
end

-- Build formspec string
function myth_inventory.get_formspec(player, tab)
    local inv_rows = myth_inventory.get_inventory_rows(player)
    local inv_height = 3 + inv_rows * 0.6
    local is_creative = minetest.is_creative_enabled(player:get_player_name())

    local formspec =
        "size[16," .. inv_height .. "]" ..
        "background[0,0;16," .. inv_height .. ";myth_ui_bg.png]" ..
        "tabheader[0.5,0;inventory_tabs;Inventory,Bags;" .. (tab == "bags" and 2 or 1) .. ";false;true]"

    if tab == "bags" then
        formspec = formspec ..
            "label[0.5,1.0;Your Bags]" ..
            "list[current_player;bag;0.5,1.5;1,3;]"
    else
        if is_creative then
            formspec = formspec ..
                "label[1.5,0.8;Creative Inventory]" ..
                "list[current_player;creative;1,1.2;5,6;]" ..
                "label[7,0.8;Your Inventory]" ..
                "list[current_player;main;6.5,1.2;9," .. inv_rows .. ";]"
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

-- Register chat command to open inventory
minetest.register_chatcommand("inventory", {
    description = "Open your inventory",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if player then
            myth_inventory.update_inventory_size(player)
            myth_inventory.show_formspec(player)
        end
    end
})

-- Unified field handler: override sfinv and handle tab switching
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "" or formname:match("^sfinv") then
        myth_inventory.show_formspec(player)
        return true
    end

    if formname:find("^myth_inventory:") then
        if fields.inventory_tabs then
            local tab_idx = tonumber(fields.inventory_tabs)
            local tab = (tab_idx == 2) and "bags" or "main"
            myth_inventory.show_formspec(player, tab)
            return true
        end
    end
end)

-- On player join: set up inventory
minetest.register_on_joinplayer(function(player)
    local inv = player:get_inventory()
    inv:set_size("main", 27)
    inv:set_size("craft", 4)
    inv:set_size("bag", 3)
    inv:set_size("creative", #creative_inventory.registered_items)

    for i, item in ipairs(creative_inventory.registered_items) do
        inv:set_stack("creative", i, ItemStack(item))
    end

    minetest.after(0.1, function()
        myth_inventory.update_inventory_size(player)
        myth_inventory.show_formspec(player)
    end)
end)

-- Prevent placing in creative inventory
minetest.register_allow_player_inventory_action(function(player, action, inventory, info)
    if info and info.listname == "creative" then
        if action == "put" then return 0 end
    end
    return nil
end)

-- Maintain infinite stacks in creative
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
