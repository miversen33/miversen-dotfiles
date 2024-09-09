local minimap_opts = {}

local init = function()
    vim.g.neominimap = {
        click = {
            enabled = true,
            auto_switch_focus = false
        },
        mark = {
            enabled = true
        }
    }
end

---@module "lazy"
---@type LazySpec
return {
    "Isrothy/neominimap.nvim",
    opts = minimap_opts,
    init = init,
    event = "VeryLazy"
}
