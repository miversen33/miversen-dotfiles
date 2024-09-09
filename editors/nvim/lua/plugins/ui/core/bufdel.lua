local bufdel_opts = {
    quit = false
}

---@module "lazy"
---@type LazySpec
return {
    "ojroques/nvim-bufdel",
    event = "VeryLazy",
    init = function()
        vim.api.nvim_create_user_command(
            'Bd',
            function(command)
                local bang = command.bang and "!" or ""
                local bufs = command.bufs or ""
                vim.cmd("BufDel" .. bang .. " " .. bufs)
            end,
            {}
        )

        vim.api.nvim_create_user_command(
            'Bdo',
            function(command)
                local bang = command.bang and "!" or ""
                vim.cmd("BufDelOthers" .. bang)
            end,
            {}
        )

        vim.api.nvim_create_user_command(
            'Bda',
            function(command)
                local bang = command.bang and "!" or ""
                vim.cmd("BufDelAll" .. bang)
            end,
            {}
        )
    end,
    opts = bufdel_opts,
}
