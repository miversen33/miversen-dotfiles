local none_ls_opts = {}

---@module "lazy"
---@type LazySpec
return {
    "nvimtools/none-ls.nvim",
    main = "null-ls",
    opts = none_ls_opts,
    enabled = false
}
