-- myth_ui/init.lua

local modpath = minetest.get_modpath(minetest.get_current_modname())
local myth_ui = {}
local hud_elements = {}

-- Utility function to include other files
local function load_file(name)
    local path = modpath .. "/" .. name
    local result, err = loadfile(path)
    if result then
        result()
    else
        minetest.log("error", "[Mythora] Failed to load: " .. name .. " - " .. err)
    end
end

-- Core loading sequence
load_file("pickblock.lua")         -- if you have global settings
load_file("commands.lua")           -- biome definitions and registrations

minetest.log("action", "[Mythora] All modules loaded successfully.")


-- Constants
local MAX_BREATH = 10
local MAX_HEALTH = 20
local MAX_HUNGER = 20
local MAX_THIRST = 10

-- XP Bar constants
local XP_BAR_POS = {x = 0.5, y = 0.9}  -- bottom center, just above hotbar
local XP_BAR_SIZE = {x = 90, y = -5}  -- adjusted shorter length
local XP_BAR_SCALE = {x = 3, y = 2}   -- scale to make bar bigger

-- Player effects state storage
local player_effects = {}
local breath_timers = {}
local player_xp = {}

-- Helper: Remove HUD elements safely
local function remove_hud(player)
    local name = player:get_player_name()
    if not hud_elements[name] then return end
    for _, elem in pairs(hud_elements[name]) do
        if type(elem) == "table" then
            for _, id in ipairs(elem) do
                player:hud_remove(id)
            end
        else
            player:hud_remove(elem)
        end
    end
    hud_elements[name] = nil
end

local function get_xp_bar_offset()
    return {
        x = -(XP_BAR_SIZE.x * XP_BAR_SCALE.x / 2),
        y = 0,
    }
end

local function init_hud(player)
    local name = player:get_player_name()
    hud_elements[name] = {}

    local base_x = 0.03
    local base_y = 0.97
    local spacing_y = 0.05
    local icon_scale = 1.6
    local text_offset_x = 0.13

    hud_elements[name].health_icon = player:hud_add({
        hud_elem_type = "image",
        position = {x = base_x, y = base_y},
        scale = {x = icon_scale, y = icon_scale},
        text = "hudbars_icon_health.png",
        alignment = {x = 0, y = 0},
    })
    hud_elements[name].health_text = player:hud_add({
        hud_elem_type = "text",
        position = {x = base_x + text_offset_x, y = base_y + 0.005},
        text = tostring(MAX_HEALTH),
        alignment = {x = 0, y = 0},
        scale = {x = 1.5, y = 1.5},
        number = 0xFF4444,
    })

    hud_elements[name].hunger_icon = player:hud_add({
        hud_elem_type = "image",
        position = {x = base_x, y = base_y - spacing_y},
        scale = {x = icon_scale, y = icon_scale},
        text = "hbhunger_icon.png",
        alignment = {x = 0, y = 0},
    })
    hud_elements[name].hunger_text = player:hud_add({
        hud_elem_type = "text",
        position = {x = base_x + text_offset_x, y = base_y - spacing_y + 0.005},
        text = tostring(MAX_HUNGER),
        alignment = {x = 0, y = 0},
        scale = {x = 1.5, y = 1.5},
        number = 0xFFD166,
    })

    hud_elements[name].thirst_icon = player:hud_add({
        hud_elem_type = "image",
        position = {x = base_x, y = base_y - spacing_y * 2},
        scale = {x = icon_scale, y = icon_scale},
        text = "thirst_hud_icon.png",
        alignment = {x = 0, y = 0},
    })
    hud_elements[name].thirst_text = player:hud_add({
        hud_elem_type = "text",
        position = {x = base_x + text_offset_x, y = base_y - spacing_y * 2 + 0.005},
        text = tostring(MAX_THIRST),
        alignment = {x = 0, y = 0},
        scale = {x = 1.5, y = 1.5},
        number = 0x4AC6FF,
    })

    hud_elements[name].breath_icon = player:hud_add({
        hud_elem_type = "image",
        position = {x = base_x, y = base_y - spacing_y * 3},
        scale = {x = icon_scale, y = icon_scale},
        text = "hudbars_icon_breath.png",
        alignment = {x = 0, y = 0},
    })
    hud_elements[name].breath_text = player:hud_add({
        hud_elem_type = "text",
        position = {x = base_x + text_offset_x, y = base_y - spacing_y * 3 + 0.005},
        text = tostring(MAX_BREATH),
        alignment = {x = 0, y = 0},
        scale = {x = 1.5, y = 1.5},
        number = 0x44FFBB,
    })

    hud_elements[name].xp_bar_bg = player:hud_add({
        hud_elem_type = "image",
        position = XP_BAR_POS,
        scale = XP_BAR_SCALE,
        offset = get_xp_bar_offset(),
        text = "myth_xp_bg.png",
        alignment = {x = 0.5, y = 0.5},
    })

    hud_elements[name].xp_bar_fg = player:hud_add({
        hud_elem_type = "image",
        position = XP_BAR_POS,
        scale = XP_BAR_SCALE,
        offset = get_xp_bar_offset(),
        text = "myth_xp_overlay.png",
        alignment = {x = 0, y = 0.5},
    })
end

function myth_ui.update(player, stats)
    local name = player:get_player_name()
    if not hud_elements[name] then return end

    if stats.health ~= nil then
        player:hud_change(hud_elements[name].health_text, "text", tostring(stats.health))
    end
    if stats.hunger ~= nil then
        player:hud_change(hud_elements[name].hunger_text, "text", tostring(stats.hunger))
    end
    if stats.thirst ~= nil then
        player:hud_change(hud_elements[name].thirst_text, "text", tostring(stats.thirst))
    end
    if stats.breath ~= nil then
        player:hud_change(hud_elements[name].breath_text, "text", tostring(stats.breath))
    end
    if stats.xp ~= nil then
        local ratio = math.max(0, math.min(1, stats.xp))
        local width = math.floor(XP_BAR_SIZE.x * ratio)
        player:hud_change(hud_elements[name].xp_bar_fg, "scale", {
            x = XP_BAR_SCALE.x * (width / XP_BAR_SIZE.x), y = XP_BAR_SCALE.y
        })
        player:hud_change(hud_elements[name].xp_bar_fg, "offset", {
            x = get_xp_bar_offset().x + (width * XP_BAR_SCALE.x / 2) - (XP_BAR_SIZE.x * XP_BAR_SCALE.x / 2),
            y = 0
        })
    end
end

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    player_effects[name] = {
        breath = MAX_BREATH,
        hunger = MAX_HUNGER,
        thirst = MAX_THIRST,
        health = MAX_HEALTH,
        xp = 0,
    }
    breath_timers[name] = 0
    player_xp[name] = 0

    player:hud_set_hotbar_itemcount(9)
    player:hud_set_flags({healthbar = false})

    init_hud(player)
    myth_ui.update(player, player_effects[name])
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    remove_hud(player)
    player_effects[name] = nil
    breath_timers[name] = nil
    player_xp[name] = nil
end)

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local effects = player_effects[name]
        if not effects then goto continue end

        breath_timers[name] = (breath_timers[name] or 0) + dtime

        if breath_timers[name] >= 1 then
            breath_timers[name] = 0

            local pos = player:get_pos()
            local head_pos = {x = pos.x, y = pos.y + 1.5, z = pos.z}
            local node = minetest.get_node_or_nil(head_pos)
            local underwater = false

            if node then
                local def = minetest.registered_nodes[node.name]
                if def and def.groups and def.groups.water then
                    underwater = true
                end
            end

            if underwater then
                if effects.breath > 0 then
                    effects.breath = effects.breath - 1
                else
                    local hp = player:get_hp()
                    if hp > 2 then
                        player:set_hp(hp - 2)
                        minetest.chat_send_player(name, "You are drowning!")
                    end
                end
            else
                effects.breath = MAX_BREATH
            end

            if effects.hunger == MAX_HUNGER then
                local hp = player:get_hp()
                if hp < MAX_HEALTH then
                    player:set_hp(hp + 1)
                end
            end

            myth_ui.update(player, {
                breath = effects.breath,
                health = player:get_hp()
            })
        end

        ::continue::
    end
end)

return myth_ui
