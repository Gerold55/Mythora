minetest.register_chatcommand("giveme", {
    params = "<node description>",
    description = "Give yourself a stack of an item by its display name",
    privs = {give = true},

    func = function(name, param)
        if not param or param == "" then
            return false, "You must specify an item description."
        end

        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end

        local match_name = nil

        -- Match description to actual node name
        for nodename, def in pairs(minetest.registered_nodes) do
            if def.description and def.description:lower() == param:lower() then
                match_name = nodename
                break
            end
        end

        if not match_name then
            return false, "No item found with that description."
        end

        local stack = ItemStack(match_name .. " 64")
        local leftover = player:get_inventory():add_item("main", stack)

        if not leftover:is_empty() then
            return true, "Inventory full; couldn't give all items."
        end

        return true, "Gave you 64 of " .. param
    end,
})

minetest.register_item(":", {
    type = "none",
    wield_image = "wieldhand.png",
    wield_scale = {x=1, y=1, z=2.5},
    range = 4.0,
    tool_capabilities = {
        full_punch_interval = 1.0,
        max_drop_level = 0,
        groupcaps = {
            crumbly = {times={[1]=1.60, [2]=1.10, [3]=0.60}, uses=0, maxlevel=1},
            snappy  = {times={[1]=1.90, [2]=1.40, [3]=0.90}, uses=0, maxlevel=1},
            choppy  = {times={[1]=2.00, [2]=1.50, [3]=1.00}, uses=0, maxlevel=1},
        },
        damage_groups = {fleshy=1},
    },
})
