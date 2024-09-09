local reactive_opts = {
    builtin = {
        cursorline = true,
        cursor = true,
        modemsg = true
    }
}

---@module "lazy"
---@type LazySpec
return {
    "rasulomaroff/reactive.nvim",
    event = "VeryLazy",
    opts = reactive_opts,
}
