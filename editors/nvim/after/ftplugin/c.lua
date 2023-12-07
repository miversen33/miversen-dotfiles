local os_sep = _G.os_sep
local codelldb_dir = vim.fn.stdpath('data') .. string.format("%smason%spackages%scodelldb", os_sep, os_sep, os_sep)


local _, dap = pcall(require, "dap")
if _ == nil then
    if not vim.g.__miversen_c_warned then
        vim.notify("dap not found!", vim.log.levels.WARN)
    end
    vim.g.__miversen_c_warned = true
    return
end

if not dap.adapters.codelldb then
    dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
            command = string.format("%s%scodelldb", codelldb_dir, os_sep),
            args = {"--port", "${port}"}
        }
    }
end

local previous_selection = ""

if not dap.configurations.c then
    dap.configurations.c = {
        {
            name = "Launch File",
            type = "codelldb",
            request = "launch",
            program = function()
                previous_selection = vim.fn.input("Path to executable: ", previous_selection)
                return previous_selection
            end,
            cwd = '${workspaceFolder}',
            stopOnEntry = false
        }
    }
end
