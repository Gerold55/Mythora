-- myth_inventory/formspecs.lua

function myth_inventory.get_survival_formspec(player)
    local name = player:get_player_name()
    return "size[10,8.5]" ..
           "label[0,0;Survival Inventory - " .. minetest.formspec_escape(name) .. "]" ..
           "list[current_player;main;1,4.5;8,4;]" ..
           "list[current_player;craft;1,1;2,2;]" ..
           "list[current_player;craftpreview;4,1;1,1;]" ..
           "button[6,1;2,1;btn_recipe_book;Recipe Book]" ..
           "listring[current_player;main]" ..
           "listring[current_player;craft]" ..
           "listring[current_player;craftpreview]"
end

function myth_inventory.get_creative_formspec(player)
    return "size[12,10]" ..
           "background[0,0;12,10;myth_ui_bg.png]" ..
           "label[0.5,0.4;Creative Inventory]" ..

           -- Creative items
           "list[creative_inventory;main;1,1.5;10,5;]" ..

           -- Hotbar
           "list[current_player;main;2,8.4;8,1;]" ..

           -- Listrings
           "listring[creative_inventory;main]" ..
           "listring[current_player;main]"
end

