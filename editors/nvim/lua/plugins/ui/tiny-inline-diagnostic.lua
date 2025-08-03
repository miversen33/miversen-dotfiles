---@type LazySpec
local tiny_diagnostic = {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000, -- needs to be loaded in first
    opts = {
        preset = "modern",
    },
}

return tiny_diagnostic
