local is_scrolling = false

local neoscroll_opts = {
    respect_scrolloff = true,
    pre_hook = function() is_scrolling = true end,
    post_hook = function() is_scrolling = false end,
}

-- TODO: Probably could add some "nice" centering of the cursor on scroll

local neoscroll_config = function()
    local neoscroll = require("neoscroll")
    neoscroll.setup(neoscroll_opts)
    local modes = {"n", "v", "i", "t"}
    local reg_time_step = 200
    local fast_time_step = 50
    vim.keymap.set(modes, '<PageUp>', function()
        if is_scrolling then return end
        neoscroll.scroll(-vim.api.nvim_win_get_height(0) + 1, true, reg_time_step)
    end)

    vim.keymap.set(modes, "<PageDown>", function()
        if is_scrolling then return end
        neoscroll.scroll(vim.api.nvim_win_get_height(0) - 1, true, reg_time_step)
    end)

    vim.keymap.set(modes, "<S-k>", function()
        if is_scrolling then return end
        neoscroll.scroll(-vim.api.nvim_win_get_height(0) - 1, true, reg_time_step)
    end)

    vim.keymap.set(modes, "<S-j>", function()
        if is_scrolling then return end
        neoscroll.scroll(vim.api.nvim_win_get_height(0) + 1, true, reg_time_step)
    end)

    vim.keymap.set(modes, "<S-Up>", function()
        if is_scrolling then return end
        neoscroll.scroll(-(vim.api.nvim_win_get_height(0) / 2), false, reg_time_step)
    end)

    vim.keymap.set(modes, "<S-Down>", function()
        if is_scrolling then return end
        neoscroll.scroll(-(vim.api.nvim_win_get_height(0) / 2), false, reg_time_step)
    end)

    vim.keymap.set(modes, "<Home>", function()
        if is_scrolling then return end
        neoscroll.scroll(-vim.api.nvim_win_get_cursor(0)[1], true, fast_time_step)
    end)

    vim.keymap.set(modes, "<End>", function()
        if is_scrolling then return end
        neoscroll.scroll(vim.api.nvim_win_get_cursor(0)[1], true, fast_time_step)
    end)

    vim.keymap.set(modes, "<S-Home>", function()
        if is_scrolling then return end
        neoscroll.scroll(vim.api.nvim_buf_line_count(0) - vim.api.nvim_win_get_cursor(0)[1], true, fast_time_step)
    end)

    vim.keymap.set(modes, "<S-End>", function()
        if is_scrolling then return end
        neoscroll.scroll(vim.api.nvim_buf_line_count(0) + vim.api.nvim_win_get_cursor(0)[1], true, fast_time_step)
    end)

    require("neoscroll.config").set_mappings()
end


local neoscroll = {
    "karb94/neoscroll.nvim",
    config = neoscroll_config
}

return neoscroll
