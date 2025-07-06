-- myth_ui/effects.lua

local effects = {}
effects.definitions = {}
effects.active_effects = {}

local S = minetest.get_translator(minetest.get_current_modname())

-- Add effect to player
function effects.add(player, effect_name, duration, stacks)
    local name = player:get_player_name()
    duration = duration or 10
    stacks = stacks or 1

    local def = effects.definitions[effect_name]
    if not def then
        minetest.chat_send_player(name, "Unknown effect: "..effect_name)
        return false
    end

    effects.active_effects[name] = effects.active_effects[name] or {}

    -- Overwrite existing effect or add new
    effects.active_effects[name][effect_name] = {
        stacks = stacks,
        duration = duration,
        start_time = os.time(),
    }

    if def.on_start then
        def.on_start(player, stacks)
    end

    minetest.chat_send_player(name, ("Effect '%s' added for %d seconds with %d stacks"):format(effect_name, duration, stacks))
    return true
end

-- Remove effect from player
function effects.remove(player, effect_name)
    local name = player:get_player_name()
    if effects.active_effects[name] and effects.active_effects[name][effect_name] then
        local def = effects.definitions[effect_name]
        if def and def.on_end then
            def.on_end(player)
        end
        effects.active_effects[name][effect_name] = nil
        minetest.chat_send_player(name, ("Effect '%s' removed"):format(effect_name))
        return true
    end
    minetest.chat_send_player(name, ("Effect '%s' not active"):format(effect_name))
    return false
end

-- Effects update step (called every second)
minetest.register_globalstep(function(dtime)
    local current_time = os.time()
    for name, player_effect_list in pairs(effects.active_effects) do
        local player = minetest.get_player_by_name(name)
        if player then
            for effect_name, effect_data in pairs(player_effect_list) do
                local def = effects.definitions[effect_name]
                if def then
                    local elapsed = current_time - effect_data.start_time
                    if elapsed >= effect_data.duration then
                        if def.on_end then def.on_end(player) end
                        player_effect_list[effect_name] = nil
                        minetest.chat_send_player(name, ("Effect '%s' expired"):format(effect_name))
                    else
                        if def.on_step then def.on_step(player, effect_data.stacks) end
                    end
                else
                    -- Unknown effect, remove it
                    player_effect_list[effect_name] = nil
                end
            end
        else
            -- Player not online, clean up effects
            effects.active_effects[name] = nil
        end
    end
end)

-- Define some example effects

-- Poison effect: damages player every second
effects.definitions["poison"] = {
    on_start = function(player, stacks)
        minetest.chat_send_player(player:get_player_name(), "You feel poisoned!")
    end,
    on_step = function(player, stacks)
        local hp = player:get_hp()
        if hp > 2 then  -- Do not kill player, leave at 2 hp minimum
            player:set_hp(hp - (1 * stacks))
        end
    end,
    on_end = function(player)
        minetest.chat_send_player(player:get_player_name(), "You are no longer poisoned.")
    end,
}

-- Blindness effect: restrict vision (placeholder, no set_fog)
effects.definitions["blindness"] = {
    on_start = function(player, stacks)
        minetest.chat_send_player(player:get_player_name(), "You are blinded! Vision is severely reduced.")
        -- TODO: implement visual overlay or shader if engine supports
    end,
    on_step = function(player, stacks)
        -- Placeholder: no active effect each step
    end,
    on_end = function(player)
        minetest.chat_send_player(player:get_player_name(), "Your vision clears up.")
        -- TODO: remove visual overlay or shader
    end,
}

-- Register chat command: /effect add/remove <effect> [duration] [stacks]
minetest.register_chatcommand("effect", {
    params = "<add/remove> <effect> [duration] [stacks]",
    description = "Manage player effects.\nExample: /effect add poison 10 2",
    func = function(name, param)
        local args = {}
        for word in param:gmatch("%S+") do
            table.insert(args, word)
        end

        local cmd = args[1]
        local effect_name = args[2]
        local duration = tonumber(args[3]) or 10
        local stacks = tonumber(args[4]) or 1

        if not cmd or not effect_name then
            return false, "Usage: /effect <add/remove> <effect> [duration] [stacks]"
        end

        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end

        if cmd == "add" then
            if not effects.definitions[effect_name] then
                return false, "Unknown effect: "..effect_name
            end
            effects.add(player, effect_name, duration, stacks)
            return true, "Effect added."
        elseif cmd == "remove" then
            effects.remove(player, effect_name)
            return true, "Effect removed if it was active."
        else
            return false, "Invalid command. Use 'add' or 'remove'."
        end
    end,
})

return effects
