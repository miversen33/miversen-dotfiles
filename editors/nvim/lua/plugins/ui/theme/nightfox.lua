
-- Uncomment this if you want to use the nightfox theme
-- vim.g.__miversen_set_theme('nightfox')
-- vim.g.__miversen_set_theme('dayfox')
-- vim.g.__miversen_set_theme('dawnfox')
-- vim.g.__miversen_set_theme('duskfox')
-- vim.g.__miversen_set_theme('nordfox')
-- vim.g.__miversen_set_theme('terafox')
-- vim.g.__miversen_set_theme('carbonfox')

local nightfox_opts = {
    options = {
        styles = {
            comments = "italic"
        }
    }
}
---@module "lazy"
---@type LazySpec
return {
    "EdenEast/nightfox.nvim", -- lazy
    lazy = false,
    priority = 1000,
    opts = nightfox_opts
}
