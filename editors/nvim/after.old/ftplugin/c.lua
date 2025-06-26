local os_sep = _G.os_sep
local codelldb_dir = vim.fn.stdpath('data') .. string.format("%smason%spackages%scodelldb", os_sep, os_sep, os_sep)


local _, dap = pcall(require, "dap")
if _ == nil then
    if not vim.g.__miversen_dap_warned then
        vim.notify("dap not found!", vim.log.levels.WARN)
    end
    vim.g.__miversen_dap_warned = true
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
                return coroutine.create(function(dap_run_co)
                    vim.ui.input({ prompt = "Executable Path:", default = previous_selection }, function(selection)
                        previous_selection = selection
                        coroutine.resume(dap_run_co, selection)
                    end)
                end)
            end,
            cwd = '${workspaceFolder}',
            stopOnEntry = false
        }
    }
end
