
-- Uncomment this if you want to set the theme to tokyonight
-- vim.g.__miversen_set_theme('tokyonight')
-- vim.g.__miversen_set_theme('tokyonight-night')
-- vim.g.__miversen_set_theme('tokyonight-storm')
-- vim.g.__miversen_set_theme('tokyonight-day')
-- vim.g.__miversen_set_theme('tokyonight-moon')

local tokyonight_opts = {}

---@module "lazy"
---@type LazySpec
return {
    "folke/tokyonight.nvim", -- Tokyo night folke theme
    priority = 1000,
    lazy = false,
    opts = tokyonight_opts
}
