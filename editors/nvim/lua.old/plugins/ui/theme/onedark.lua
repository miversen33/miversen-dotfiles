-- Uncomment this if you want to use onedark theme
-- vim.g.__miversen_set_theme('onedark')

local is_transparent = true
local onedark_opts = {
    style = "darker",
    -- style = "dark",
    -- style = "cool",
    -- style = "deep",
    -- style = "warm",
    -- style = "warmer",
    -- style = "light",
    transparent = is_transparent,
    lualine = {
        transparent = is_transparent
    }
}

---@module "lazy"
---@type LazySpec
return {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    opt = onedark_opts
}
