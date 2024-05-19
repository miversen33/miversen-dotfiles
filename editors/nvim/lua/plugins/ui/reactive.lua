local reactive_opts = {
    builtin = {
        cursorline = true,
        cursor = true,
        modemsg = true
    }
}

local reactive = {
    "rasulomaroff/reactive.nvim",
    opts = reactive_opts,
    config = true,
    enabled = true
}

return reactive
