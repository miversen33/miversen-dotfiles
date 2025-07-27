---@module "illuminate"
local illuminate_opts = {
    providers = {
        "lsp",
        "regex",
        -- Omitting treesitter for now because I don't trust it with big files...
        "treesitter"
    },
    filetypes_denylist = vim.g.excluded_filetypes
}

---@module "lazy"
---@type LazySpec
return {
    "RRethy/vim-illuminate",
    name = "illuminate",
    event = "VeryLazy",
    config = function(_, opts)
        require("illuminate").configure(opts)
    end,
    opts = illuminate_opts,
}
