-- Uncomment this if you want to set the theme to aura theme
-- vim.g.__miversen_set_theme('aura-dark', 'ayu_dark')
-- vim.g.__miversen_set_theme('aura-dark-soft-text', 'ayu_dark')
-- vim.g.__miversen_set_theme('aura-soft-dark', 'ayu_dark')
-- vim.g.__miversen_set_theme('aura-soft-dark-soft-text', 'ayu_dark')

local aura_opts = {}

---@module "lazy"
---@type LazySpec
return {
    "daltonmenezes/aura-theme", -- Aura theme
    lazy = false,
    priority = 1000,
    config = function(plugin)
        vim.opt.rtp:append(plugin.dir .. "/packages/neovim")
    end,
    opts = aura_opts
}
