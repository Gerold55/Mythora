-- myth_ui/init.lua

local myth_ui = {}

local hud_elements = {}

-- Helper function to safely remove HUD elements
local function remove_hud(player)
    local name = player:get_player_name()
    if not hud_elements[name] then return end

    for key, element in pairs(hud_elements[name]) do
        if type(element) == "table" then
            for _, id in ipairs(element) do
                player:hud_remove(id)
            end
        else
            player:hud_remove(element)
        end
    end

    hud_elements[name] = nil
end

-- Initialize HUD elements for a player
local function init_hud(player)
    local name = player:get_player_name()
    hud_elements[name] = {}

    local base_x = 0.03  -- Left side
    local base_y = 0.97
    local spacing = 0.03

    -- Health
    hud_elements[name].health = player:hud_add({
        hud_elem_type = "statbar",
        position = {x = base_x, y = base_y},
        text = "myth_heart.png",
        number = 20,
        direction = 0,
        size = {x = 24, y = 24},
        alignment = {x = 0, y = 0},
        offset = {x = 0, y = 0},
    })

    -- Armor
    hud_elements[name].armor = player:hud_add({
        hud_elem_type = "statbar",
        position = {x = base_x, y = base_y - spacing},
        text = "myth_armor.png",
        number = 20,
        direction = 0,
        size = {x = 24, y = 24},
        alignment = {x = 0, y = 0},
        offset = {x = 0, y = 0},
    })

    -- Hunger
    hud_elements[name].hunger = {}
    for i = 1, 10 do
        local id = player:hud_add({
            hud_elem_type = "image",
            position = {x = base_x + (i - 1) * 0.025, y = base_y - 2 * spacing},
            offset = {x = 0, y = 0},
            scale = {x = 1, y = 1},
            text = "myth_food_full.png",
            alignment = {x = 0, y = 0},
        })
        table.insert(hud_elements[name].hunger, id)
    end

    -- Hide default hotbar and move hotbar to right if supported
    if player.hud_set_hotbar_visible then
        player:hud_set_hotbar_visible(false)
    end

    if player.hud_set_hotbar_itemcount then
        player:hud_set_hotbar_itemcount(10)
    end

    if player.hud_set_hotbar_image then
        player:hud_set_hotbar_image("myth_hotbar_bg.png")
    end

    if player.hud_set_hotbar_selected_image then
        player:hud_set_hotbar_selected_image("myth_hotbar_select.png")
    end

    if player.hud_set_hotbar_position then
        -- Right side, near bottom
        player:hud_set_hotbar_position({x = 0.95, y = 0.97})
    end

    if player.hud_set_hotbar_alignment then
        player:hud_set_hotbar_alignment({x = 1, y = 1})
    end
end

-- Update HUD values
function myth_ui.update(player, stats)
    local name = player:get_player_name()
    if not hud_elements[name] then return end

    if stats.health then
        player:hud_change(hud_elements[name].health, "number", stats.health)
    end

    if stats.armor then
        player:hud_change(hud_elements[name].armor, "number", stats.armor)
    end

    if stats.hunger then
        local hunger_icons = hud_elements[name].hunger
        local hunger = stats.hunger or 0

        for i = 1, 10 do
            local icon = "myth_food_empty.png"
            if i <= hunger then
                icon = "myth_food_full.png"
            elseif i - 0.5 == hunger then
                icon = "myth_food_half.png"
            end
            player:hud_change(hunger_icons[i], "text", icon)
        end
    end
end

-- Handle player join/leave
minetest.register_on_joinplayer(function(player)
    init_hud(player)
end)

minetest.register_on_leaveplayer(function(player)
    remove_hud(player)
end)

return myth_ui
