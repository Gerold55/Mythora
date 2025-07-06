-- Example recipe book interface
myth_inventory.known_recipes = {}

-- Dummy data for now
myth_inventory.known_recipes["default:wood"] = {
    output = "default:wood 4",
    input = { "default:tree" }
}

function myth_inventory.get_recipe_formspec(player)
    local fs = {
        "formspec_version[4]",
        "size[10,8]",
        "label[0.5,0.5;Recipe Book]",
        "button_exit[7.5,7.5;2,1;exit;Close]",
    }

    local row = 0
    for item, recipe in pairs(myth_inventory.known_recipes) do
        fs[#fs+1] = string.format("item_image[0.5,%f;1,1;%s]", 1 + row, item)
        fs[#fs+1] = string.format("label[2,%f;= %s from %s]", 1 + row, recipe.output, table.concat(recipe.input, ", "))
        row = row + 1
    end

    return table.concat(fs, "")
end

minetest.register_chatcommand("recipes", {
    description = "Open the recipe book",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        minetest.show_formspec(name, "myth_inventory:recipes", myth_inventory.get_recipe_formspec(player))
        return true
    end
})
