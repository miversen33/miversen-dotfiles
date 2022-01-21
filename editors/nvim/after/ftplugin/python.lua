-- Sets a basic auto loader for the dap
-- if exists('b:did_ftplugin') then
    -- finish
-- end

local dap = require('dap')
local job = require('plenary.job')

local fn = vim.fn
local notify = vim.notify

local dap_path = fn.stdpath('data')..'/dap'
local python_path = dap_path..'/python'

local function setup_python_adapter()
    dap.adapters.python = {
        type = 'executable',
        command = python_path..'/virtualenv/bin/python',
        args = { '-m', 'debugpy.adapter' }
    }
end

if dap.adapters['python'] == nil then
    -- Setting up dap for python
    if fn.empty(fn.glob(dap_path)) > 0 then
        fn.system({'mkdir', '-p', dap_path})
    end
    if fn.empty(fn.glob(python_path)) > 0 then
        fn.system({'mkdir', '-p', python_path})
    end
    if fn.empty(fn.glob(python_path..'/virtualenv')) > 0 then
        notify("Installing Python DAP...", INFO)
        job:new({
            command = '/usr/bin/python3',
            args = {'-m', 'virtualenv', 'virtualenv'},
            cwd = python_path,
        }):sync()
        job:new({
            command = python_path..'/virtualenv/bin/pip',
            args = {'install', 'debugpy'},
            cwd = python_path,
            on_exit = setup_python_adapter
        }):start()
    else
        setup_python_adapter()
    end
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
