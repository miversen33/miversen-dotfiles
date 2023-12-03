-- Minimal configuration
-- mini.lua
-- Use with the --clean -u flags. EG nvim --clean -u mini.lua
-- This config will create a temp directory and will blow away that temp directory
-- everytime this configuration is loaded. Great for simulating a new installation
-- of a plugin

-- Setting some basic vim options
-- Some junk because I am sick of formatting tables in print
local _print = _G.print
local clean_string = function(...)
    local args = { n = select("#", ...), ... }
    local formatted_args = {}
    for i = 1, args.n do
        local item = select(i, ...)
        if not item then item = 'nil' end
        local t_type = type(item)
        if t_type == 'table' or t_type == 'function' or t_type == 'userdata' then
            item = vim.inspect(item)
        end
        table.insert(formatted_args, item)
    end
    return table.concat(formatted_args, ' ')
end
_G.print = function(...)
    _print(clean_string(...))
end

vim.opt.mouse = 'a'
vim.opt.termguicolors = true
-- If you want to play around with this, you can set the do_clean
-- variable to false. This will allow changes made to
-- underlying plugins to persist between sessions, while
-- still keeping everything in its own directory so
-- as to not affect your existing neovim installation.
--
-- Setting this to true will result in a fresh clone of
-- all modules
local do_clean = false
local sep = vim.loop.os_uname().sysname:lower():match('windows') and '\\' or
'/'                                                                              -- \ for windows, mac and linux both use \
local root = vim.fn.fnamemodify("./.repro", ":p")
if vim.loop.fs_stat(root) and do_clean then
    print("Found previous clean test setup. Cleaning it out")
    -- Clearing out the mods directory and recreating it so
    -- you have a fresh run everytime
    vim.fn.delete(root, 'rf')
end

-- DO NOT change the paths and don't remove the colorscheme

-- set stdpaths to use .repro
for _, name in ipairs({ "config", "data", "state", "cache" }) do
    vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
end

-- bootstrap lazy
local lazypath = root .. "/plugins/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath, })
end
vim.opt.runtimepath:prepend(lazypath)

-- install plugins
local plugins = {
    "folke/tokyonight.nvim",
    -- add any other plugins here
}

require("lazy").setup(plugins, {
    root = root .. "/plugins",
    dev = {
        path = "~/git",
        patterns = {
            "miversen33",
        },
        fallback = true
    },
})

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.cmd.colorscheme("tokyonight")
-- add anything else here
