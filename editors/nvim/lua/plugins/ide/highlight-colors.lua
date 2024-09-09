local highlight_colors_opts = {
    enable_tailwind = true
}

---@module "lazy"
---@type LazySpec
return {
    "brenoprata10/nvim-highlight-colors",
    opts = highlight_colors_opts,
    event = "VeryLazy"
}
