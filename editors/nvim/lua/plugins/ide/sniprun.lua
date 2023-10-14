local sniprun_opts = {
    display = { "VirtualTextOk", "TerminalWithCodeErr" }
}

local sniprun = {
    "michaelb/sniprun",
    build = "sh install.sh",
    config = true,
    opts = sniprun_opts
}

return sniprun
