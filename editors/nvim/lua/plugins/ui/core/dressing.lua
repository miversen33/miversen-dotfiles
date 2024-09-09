local dressing_opts = {
    input = {
        relative = "editor"
    }
}

---@module "lazy"
---@type LazySpec
return {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = dressing_opts
}
