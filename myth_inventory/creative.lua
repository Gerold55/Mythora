local S = minetest.get_translator("myth_inventory")

myth_inventory.creative_items = {}

-- Populate creative inventory once
minetest.register_on_mods_loaded(function()
    for name, def in pairs(minetest.registered_items) do
        if not def.groups.not_in_creative_inventory then
            table.insert(myth_inventory.creative_items, name)
        end
    end
    table.sort(myth_inventory.creative_items)
end)

-- Returns a formspec page of creative items
function myth_inventory.get_creative_formspec(player, pagenum)
    pagenum = pagenum or 1
    local per_page = 40
    local total = #myth_inventory.creative_items
    local pages = math.ceil(total / per_page)
    local start = (pagenum - 1) * per_page + 1
    local items = ""

    for i = start, math.min(start + per_page - 1, total) do
        local x = ((i - start) % 10) * 1.1
        local y = math.floor((i - start) / 10) * 1.1
        items = items .. string.format("item_image_button[%f,%f;1,1;%s;%s;]", x, y, myth_inventory.creative_items[i], myth_inventory.creative_items[i])
    end

    return table.concat({
        "formspec_version[4]",
        "size[12,9]",
        "label[0.3,0.2;Creative Inventory]",
        items,
        string.format("button[9.5,7.5;2,1;prev;< Prev]"),
        string.format("button[11.5,7.5;2,1;next;Next >]"),
        string.format("label[5,8.2;Page %d of %d]", pagenum, pages),
        "button_exit[10,8.5;2,1;exit;Close]"
    }, "")
end

-- Handle item giving
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "myth_inventory:creative" then return end
    local name = player:get_player_name()

    for key, _ in pairs(fields) do
        if key == "prev" or key == "next" then
            local page = tonumber(player:get_meta():get_string("creative_page")) or 1
            page = (key == "next") and (page + 1) or (page - 1)
            if page < 1 then page = 1 end
            player:get_meta():set_string("creative_page", tostring(page))
            minetest.show_formspec(name, "myth_inventory:creative", myth_inventory.get_creative_formspec(player, page))
            return true
        elseif minetest.registered_items[key] then
            player:get_inventory():add_item("main", key)
            return true
        end
    end
end)
