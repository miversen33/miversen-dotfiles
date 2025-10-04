local catppuccin_opts = {
    default_integrations = false,
    transparent_background = true,
    integrations = {
        dap = true,
        fidget = true,
        gitsigns = true,
        illuminate = true,
        cmp = true,
        -- "nvim-web-devicons",
        lsp_trouble = true,
        notify = true,
        aerial = true
    }
}

-- Uncomment this if you want to set the theme to catppuccin
-- vim.g.__miversen_set_theme('catppuccin')
-- vim.g.__miversen_set_theme('catppuccin-frappe')
-- vim.g.__miversen_set_theme('catppuccin-macchiato')
vim.g.__miversen_set_theme('catppuccin-mocha')

---@type LazySpec
return {
    "catppuccin/nvim", -- catppuccin theme
    name = "catppuccin",
    opts = catppuccin_opts,
    priority = 1000,
    lazy = false
}
