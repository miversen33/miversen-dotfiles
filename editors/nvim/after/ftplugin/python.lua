-- Sets a basic auto loader for the dap
-- if exists('b:did_ftplugin') then
    -- finish
-- end

local dap = require('dap')
if dap.adapters['python'] == nil then
    -- Setting up dap for python
    dap.adapters.python = {
        type = 'executable',
        command = '/usr/bin/python3', -- Consider installing a virtualenv for the dap in ~/.local/share/nvim/dap/python/virtualenv
        args = { '-m', 'debugpy.adapter' }
    }
end

dap.configurations.python = {
    {
    -- The first three options are required by nvim-dap
    type = 'python', -- the type here established the link to the adapter definition: `dap.adapters.python`
    request = 'launch',
    name = "Launch file",

    -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

    program = "${file}", -- This configuration will launch the current file if used.
    pythonPath = function()
         -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
         -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
         -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
        local cwd = vim.fn.getcwd()
        if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
            return cwd .. '/venv/bin/python'
        elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
            return cwd .. '/.venv/bin/python'
        else
            return '/usr/bin/python'
        end
    end,
    },
}

-- let b:did_ftplugin = 1
