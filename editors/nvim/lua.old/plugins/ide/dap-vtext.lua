---@module "lazy"
---@type LazySpec
return {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate"
}
