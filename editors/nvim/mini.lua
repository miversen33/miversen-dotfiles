-- Minimal configuration
-- mini.lua
-- Use with the --clean -u flags. EG nvim --clean -u mini.lua
-- This config will create a temp directory and will blow away that temp directory
-- everytime this configuration is loaded. Great for simulating a new installation
-- of a plugin

-- Setting some basic vim options
vim.opt.termguicolors = true

local sep = vim.loop.os_uname().sysname:lower():match('windows') and '\\' or '/' -- \ for windows, mac and linux both use \

local mod_path = string.format("%s%sclean-test%s", vim.fn.stdpath('cache'), sep, sep)
if vim.loop.fs_stat(mod_path) then
    print("Found previous clean test setup. Cleaning it out")
    -- Clearing out the mods directory and recreating it so 
    -- you have a fresh run everytime
    vim.fn.delete(mod_path, 'rf')
end

vim.fn.mkdir(mod_path, 'p')

local modules = {
    {'nvim-lua/plenary.nvim'},
    {'nvim-tree/nvim-web-devicons'},
    {'MunifTanjim/nui.nvim'},
    {'nvim-neo-tree/neo-tree.nvim', branch = "main", mod = "neo-tree"},
}

for _, module in ipairs(modules) do
    local repo = module[1]
    local branch = module.branch
    local module_name = repo:match('/(.*)')
    local module_path = string.format('%s%s%s', mod_path, sep, module_name)
    if not vim.loop.fs_stat(module_name) then
        -- The module doesn't exist, download it
        local cmd = {
            'git',
            'clone'
        }
        if branch then
            table.insert(cmd, '--branch')
            table.insert(cmd, branch)
        end
        table.insert(cmd, string.format('https://github.com/%s', repo))
        table.insert(cmd, module_path)
        vim.fn.system(cmd)
        local message = string.format("Downloaded %s", module_name)
        if branch then
            message = string.format("%s on branch %s", message, branch)
        end
        print(message)
    end
    vim.opt.runtimepath:append(module_path)
end

print("Finished installing plugins. Beginning Setup of plugins")

for _, module in ipairs(modules) do
    if module.mod then
        print(string.format("Loading %s", module.mod))
        local success, module = pcall(require, module.mod)
        if not success then
            print(string.format("Failed to load module %s", module.mod))
            error(module)
        end
    end
end

-- --> Do you module setups below this line <-- --

-- --> Do your module setups above this line <-- --

print("Completed minimal setup!")
