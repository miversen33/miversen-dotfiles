---@module "dap-view"
---@type dapview.Config
local dap_view_opts = {}

---@type LazySpec
local dap_ui = {
    "igorlfs/nvim-dap-view",
    opts = dap_view_opts
}

---@module "nvim-dap-virtual-text"
---@type nvim_dap_virtual_text_options
local dap_vt_opts = {
    show_stop_reason = false,
}

---@type LazySpec
local dap_vt = {
    "theHamsta/nvim-dap-virtual-text",
    opts = dap_vt_opts,
}

---@type LazySpec
local dap = {
    "https://codeberg.org/mfussenegger/nvim-dap.git",
    dependencies = {
        dap_ui,
        dap_vt
    },
    init = function()
        vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#45475a" })
        vim.fn.sign_define('DapBreakpoint', { text = ' ', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
        vim.fn.sign_define('DapBreakpointCondition',
            { text = ' ', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' })
        vim.fn.sign_define('DapLogPoint', { text = ' ', texthl = 'DapLogPoint', linehl = '', numhl = '' })
        vim.fn.sign_define('DapStopped',
            { text = ' ', texthl = 'DapStopped', linehl = 'DapStoppedLine', numhl = 'DapStoppedLine' })
        vim.fn.sign_define('DapBreakpointRejected',
            { text = '󰔒 ', texthl = 'DapBreakpointRejected', linehl = '', numhl = '' })
    end,
    config = function()
        local _, _dap = pcall(require, "dap")
        if not _ then
            -- Unable to import dap
            vim.notify("Unable to load dap, cannot set mappings!", vim.log.levels.WARN)
            return
        end
        local overwritten_maps = {}
        local function reset_mappings()
            pcall(vim.keymap.del, 'n', '<Down>')
            pcall(vim.keymap.del, 'n', '<Right>')
            pcall(vim.keymap.del, 'n', '<Left>')
            pcall(vim.keymap.del, 'n', '<Up>')
            for _, mapping in ipairs(overwritten_maps) do
                vim.keymap.set(mapping.mode, mapping.lhs, mapping.rhs, {
                    buffer = mapping.buffer,
                    nowait = mapping.nowait,
                    silent = mapping.silent,
                    script = mapping.script,
                    unique = mapping.unique
                })
            end
        end
        _dap.listeners.before['event_stopped']['miversen33_config'] = function(_, _)
            require("dap-view").open()
            local normal_keymaps = vim.api.nvim_get_keymap("n")
            for _, mapping in ipairs(normal_keymaps) do
                local lhs = mapping.lhs and mapping.lhs:lower() or ''
                local rhs = mapping.rhs
                if rhs and (lhs == '<down>' or lhs == '<left>' or lhs == '<right>' or lhs == '<up>') then
                    table.insert(overwritten_maps, mapping)
                end
            end
            vim.keymap.set('n', '<Down>', require("dap").step_over, { desc = "Steps over current break point" })
            vim.keymap.set('n', '<Right>', require("dap").step_into, { desc = "Steps into the current breakpoint" })
            vim.keymap.set('n', '<Left>', require("dap").step_out, { desc = "Steps out of the current breakpoint frame" })
            vim.keymap.set('n', '<Up>', require("dap").restart_frame, { desc = "Restarts the frame" })
        end
        _dap.listeners.after['event_terminated']['miversen33_config'] = reset_mappings
        _dap.listeners.after['event_exited']['miversen33_config'] = reset_mappings
    end
}

return dap
