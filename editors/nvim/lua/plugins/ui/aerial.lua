local aerial_opts = {

}
local init = function ()
    vim.keymap.set("n", '<leader>o', '<cmd>AerialToggle<CR>')
end

---@module "lazy"
---@type LazySpec
return {
    "stevearc/aerial.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons"
    },
    init = init,
    opts = aerial_opts,
}
