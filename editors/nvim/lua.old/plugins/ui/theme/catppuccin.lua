local catppuccin_opts = {
    default_integrations = false,
    transparent_background = true,
    integrations = {
        "dap",
        "fidget",
        "gitsigns",
        "illuminate",
        "neotree",
        "cmp",
        -- "nvim-web-devicons",
        "lsp_trouble",
        "notify",
        "aerial"
    }
}

-- Uncomment this if you want to set the theme to catppuccin
-- vim.g.__miversen_set_theme('catppuccin')
-- vim.g.__miversen_set_theme('catppuccin-frappe')
-- vim.g.__miversen_set_theme('catppuccin-macchiato')
vim.g.__miversen_set_theme('catppuccin-mocha')

---@module "lazy"
---@type LazySpec
return {
    "catppuccin/nvim", -- catppuccin theme
    name = "catppuccin",
    opts = catppuccin_opts,
    priority = 1000,
    lazy = false
}
