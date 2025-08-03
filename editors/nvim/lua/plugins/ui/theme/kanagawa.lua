-- Uncomment this if you want to use kanagawa theme
-- vim.g.__miversen_set_theme("kanagawa-dragon", "auto")

local kanagawa_opts = {

}


---@type LazySpec
return {
    "rebelot/kanagawa.nvim",
    opts = kanagawa_opts,
    lazy = false,
    priority = 1000
}
