-- Uncomment this to use nordic theme
-- vim.g.__miversen_set_theme("nordic")

local nordic_opts = {}

---@module "lazy"
---@type LazySpec
return {
    "AlexvZyl/nordic.nvim",
    lazy = false,
    priority = 1000,
    opts = nordic_opts
}
