local neoscroll_opts = {}
local neoscroll_mappings = {
    ['<PageUp>']   = {'scroll', { '-vim.api.nvim_win_get_height(0) + 1 ', 'true', '200'}},
    ['<S-k>']      = {'scroll', { '-vim.api.nvim_win_get_height(0) + 1 ', 'true', '200'}},
    ['<PageDown>'] = {'scroll', { 'vim.api.nvim_win_get_height(0) - 1', 'true', '200'}},
    ['<S-j>']      = {'scroll', { 'vim.api.nvim_win_get_height(0) - 1', 'true', '200'}},
    ['<Home>'] = {'scroll', { '-vim.api.nvim_win_get_cursor(0)[1]', 'true', '50'}},
    ['<S-Home>'] = {'scroll', {'vim.api.nvim_buf_line_count(0) - vim.api.nvim_win_get_cursor(0)[1]', 'true', '50'}},
    ['<S-Up>'] = {'scroll', { '-(vim.api.nvim_win_get_height(0) / 2)', 'false', '200'}},
    ['<S-Down>'] = {'scroll', {'vim.api.nvim_win_get_height(0) / 2', 'false', '200'}}
}


local neoscroll = {
    "karb94/neoscroll.nvim",
    config = function()
        local neoscroll = require("neoscroll")
        neoscroll.setup(neoscroll_opts)
        require("neoscroll.config").set_mappings(neoscroll_mappings)
        -- vim.keymap.set()
    end
}

return neoscroll
