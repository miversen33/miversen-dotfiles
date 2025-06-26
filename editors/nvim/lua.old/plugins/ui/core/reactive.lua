local reactive_opts = {
    builtin = {
        cursorline = true,
        cursor = true,
        modemsg = true
    },
    load = {
        "catppuccin-mocha-cursor",
        "catppuccin-mocha-cursorline"
    }
}

---@module "lazy"
---@type LazySpec
return {
    "rasulomaroff/reactive.nvim",
    event = "VeryLazy",
    opts = reactive_opts,
}
