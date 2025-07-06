-- myth_ui/hb_registrations.lua

local hb = hb or {}

hb.register_hudbar("health", 0xFF0000, "Health", {
    bar = "hb_health_bar.png",
    icon = "myth_heart.png"
}, 20, 20, false)

hb.register_hudbar("armor", 0xCCCCCC, "Armor", {
    bar = "hb_armor_bar.png",
    icon = "myth_armor.png"
}, 0, 20, false)

hb.register_hudbar("hunger", 0xFFD700, "Hunger", {
    bar = "hb_hunger_bar.png",
    icon = "myth_food_full.png"
}, 20, 20, false)

-- You can also register more later: mana, stamina, XP, water, etc.
