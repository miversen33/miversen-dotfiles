local catppuccin_opts = {}

-- Uncomment this if you want to set the theme to catppuccin
-- vim.g.__miversen_set_theme('catppuccin')
-- vim.g.__miversen_set_theme('catppuccin-frappe')
-- vim.g.__miversen_set_theme('catppuccin-macchiato')
-- vim.g.__miversen_set_theme('catppuccin-mocha')

---@module "lazy"
---@type LazySpec
return {
    "catppuccin/nvim", -- catppuccin theme
    name = "catppuccin",
    priority = 1000,
    lazy = false
}
