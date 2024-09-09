local markview_opts = {}

---@module "lazy"
---@type LazySpec
return {
    "OXY2DEV/markview.nvim",
    opts = markview_opts,
    ft = {'markdown'},
    enabled = false,
}
