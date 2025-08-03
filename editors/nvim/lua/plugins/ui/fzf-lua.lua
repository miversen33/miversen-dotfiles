---@type LazySpec
local fzf = {
    "ibhagwan/fzf-lua",
    dependencies = {
        "echasnovski/mini.icons"
    },
    opts = {
        winopts = {
            border = "rounded",
        },
    },
    config = function()
        require("fzf-lua").register_ui_select()
    end,
    cmd = "FzfLua",
    lazy = true,
}

return fzf
