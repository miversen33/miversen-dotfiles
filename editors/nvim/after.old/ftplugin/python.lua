local os_sep = _G.os_sep
local debugpy_dir = vim.fn.stdpath('data') .. string.format("%smason%spackages%sdebugpy", os_sep, os_sep, os_sep)
local _1, dap = pcall(require, "dap")

local basic_settings = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
end

local setup_dap = function()
    if _1 == nil then
        if not vim.g.__miversen_dap_warned then
            vim.notify("dap not found!", vim.log.levels.WARN)
        end
        vim.g.__miversen_dap_warned = true
        return
    end
    local _2, dap_python = pcall(require, "dap-python")
    if _2 == nil then
        if not vim.g.__miversen_python_warned then
            vim.notify("dap-python not foud!", vim.log.levels.WARN)
        end
        vim.g.__miversen_python_warned = true
        return
    end
    dap.configurations.python = {}
    dap_python.setup(string.format("%s%svenv%sbin%spython", debugpy_dir, os_sep, os_sep, os_sep))
end

basic_settings()
setup_dap()
