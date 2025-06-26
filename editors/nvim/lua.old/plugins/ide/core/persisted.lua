local persisted_opts = {
    use_git_branch = true,
    should_autosave = true,
    autostart = false,
    -- autoload = true,
    ignored_dirs = {
        "/tmp",
        {"/", exact = true},
        {vim.uv and vim.uv.os_homedir() or vim.loop.os_homedir(), exact = true}
    }
}

local function auto_session_restore()
    vim.schedule(function()
        require("persisted").start()
        if not next(vim.fn.argv()) then
            require("persisted").load()
        end
    end)
end

local lazy_view_win = nil
vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
        local lazy_view = require("lazy.view")

        if lazy_view.visible() then
            lazy_view_win = lazy_view.view.win
        else
            auto_session_restore()
        end
    end,
})

vim.api.nvim_create_autocmd("ExitPre", {
    desc = "close all unwanted buffers/windows before sessioning",
    callback = function()
        local UNWANTED_SESSION_BUFFERTYPES = {
            "dapui_*",
            "dap-*"
        }
        local buffers = vim.api.nvim_list_bufs()
        for _, buffer_index in ipairs(buffers) do
            local buftype = vim.api.nvim_get_option_value("filetype", { buf = buffer_index })
            for _, filter in ipairs(UNWANTED_SESSION_BUFFERTYPES) do
                if buftype:match(filter) then
                    -- Close the buffer
                    vim.api.nvim_buf_delete(buffer_index, { force = true})
                end
            end
        end
    end
})

vim.api.nvim_create_autocmd("WinClosed", {
    callback = function(event)
        if not lazy_view_win or event.match ~= tostring(lazy_view_win) then
            return
        end

        auto_session_restore()
    end,
})

---@module "lazy"
---@type LazySpec
return {
    "olimorris/persisted.nvim",
    opts = persisted_opts,
    lazy = true
}
