local init = function()
    ---@module "neominimap.config.meta"
    ---@type Neominimap.UserConfig
    vim.g.neominimap = {
        click = {
            enabled = true,
            auto_switch_focus = false
        },
        mark = {
            enabled = true
        },
        auto_enable = false
    }
end

---@module "lazy"
---@type LazySpec
return {
    "Isrothy/neominimap.nvim",
    init = init,
    lazy = false,
}
