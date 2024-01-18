local bufdel_opts = {
    quit = false
}

local setup_bufdel = function()
    require("bufdel").setup(bufdel_opts)
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
        'Bda',
        function(command)
            local bang = command.bang and "!" or ""
            vim.cmd("BufDelOthers" .. bang)
        end,
        {}
    )
end

local bufdel = {
    "ojroques/nvim-bufdel",
    config = setup_bufdel
}

return bufdel
