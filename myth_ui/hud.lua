-- myth_ui/hud.lua

local hud_elements = {}

-- Initialize HUD for player
local function init_hud(player)
    local name = player:get_player_name()
    hud_elements[name] = {}

    -- Health bar
    hud_elements[name].health = player:hud_add({
        hud_elem_type = "statbar",
        position = {x = 0.05, y = 0.9},
        text = "myth_heart.png",
        number = player:get_hp() / 2,
        direction = 0,
        size = {x = 24, y = 24},
        alignment = {x = 1, y = 0},
        offset = {x = 0, y = 0}
    })

    -- Armor bar
    hud_elements[name].armor = player:hud_add({
        hud_elem_type = "statbar",
        position = {x = 0.05, y = 0.95},
        text = "myth_armor.png",
        number = 10,
        direction = 0,
        size = {x = 24, y = 24},
        alignment = {x = 1, y = 0},
        offset = {x = 0, y = 0}
    })

    -- Hunger bar
    hud_elements[name].hunger = player:hud_add({
        hud_elem_type = "statbar",
        position = {x = 0.95, y = 0.9},
        text = "myth_food.png",
        number = 10,
        direction = 0,
        size = {x = 24, y = 24},
        alignment = {x = -1, y = 0},
        offset = {x = 0, y = 0}
    })

    -- Thirst bar
    hud_elements[name].thirst = player:hud_add({
        hud_elem_type = "statbar",
        position = {x = 0.95, y = 0.95},
        text = "myth_water.png",
        number = 10,
        direction = 0,
        size = {x = 24, y = 24},
        alignment = {x = -1, y = 0},
        offset = {x = 0, y = 0}
    })
end

-- Update all HUD elements (to be used by other mods)
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
        player:hud_change(hud_elements[name].hunger, "number", stats.hunger)
    end
    if stats.thirst then
        player:hud_change(hud_elements[name].thirst, "number", stats.thirst)
    end
end

-- Hook into player join
minetest.register_on_joinplayer(function(player)
    minetest.after(1, function()
        init_hud(player)
    end)
end)
