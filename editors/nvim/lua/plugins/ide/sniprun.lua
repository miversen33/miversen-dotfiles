local sniprun_opts = {
    display = { "VirtualTextOk", "TerminalWithCodeErr" }
}

---@module "lazy"
---@type LazySpec
return {
    "michaelb/sniprun",
    build = "sh install.sh",
    event = "VeryLazy",
    opts = sniprun_opts
}
