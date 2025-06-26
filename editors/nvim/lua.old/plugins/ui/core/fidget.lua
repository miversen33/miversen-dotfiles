local fidget_opts = {
    progress = {
        display = {
            render_limit = 10,
        },
        ignore_done_already = true,
        ignore_empty_message = true,
    },
    notification = {
        window = {
            winblend = 0,
            border = "rounded",
        }
    }
}

local fidget = {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = fidget_opts
}

return fidget
