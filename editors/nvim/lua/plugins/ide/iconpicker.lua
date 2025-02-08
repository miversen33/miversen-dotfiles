---@module "lazy"
---@type LazySpec
return {
    "ziontee113/icon-picker.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "stevearc/dressing.nvim",
    },
    opts = {},
    cmd = {
        "IconPickerNormal",
        "IconPickerInsert",
        "IconPickerYank"
    }
}
