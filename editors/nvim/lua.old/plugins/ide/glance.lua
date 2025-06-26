local glance_opts = {
    height = 25,
    border = {
        enable = true,
        top_char = '─',
        bottom_char = '─'
    },
    list = {
        position = "left"
    },
    theme = {
        mode = "darken"
    }
}

---@module "lazy"
---@type LazySpec
return {
    "dnlhc/glance.nvim",
    event = "VeryLazy",
    opts = glance_opts
}
