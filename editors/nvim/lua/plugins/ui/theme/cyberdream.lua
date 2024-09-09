
-- Uncomment if you want to use cyberdream theme
-- vim.g.__miversen_set_theme("cyberdream", "auto")

local cyberdream_opts = {
    italic_comments = true,
    hide_fillchars = true,
    transparent = true
}

---@module "lazy"
---@type LazySpec
return {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = cyberdream_opts
}
