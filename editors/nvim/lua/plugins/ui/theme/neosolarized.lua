-- Uncomment if you want to use neosolarized theme
-- vim.g.__miversen_set_theme("NeoSolarized")

local neosolarized_opts = {}

---@module "lazy"
---@type LazySpec
return {
    "Tsuzat/NeoSolarized.nvim",
    lazy = false,
    priority = 1000,
    opts = neosolarized_opts
}
