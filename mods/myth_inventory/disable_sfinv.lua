-- Disable sfinv globally so it won't interfere

rawset(_G, "sfinv", {
    pages = {},
    pages_unordered = {},
    contexts = {},
    enabled = false,
    default_page = nil,
    register_page = function() end,
    set_player_inventory_formspec = function() end,
})
