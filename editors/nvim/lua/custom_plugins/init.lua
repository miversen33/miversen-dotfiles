local custom_plugins_path = vim.fn.stdpath('config') .. '/lua/custom_plugins/'
local dir_handle = vim.loop.fs_scandir(custom_plugins_path)

-- Ensure the custom config exists
local sysname = vim.loop.os_uname().sysname:lower()
local sep = sysname:match('windows') and '\\' or '/' -- \ for windows, mac and linux both use \
local config = string.format("%s%s%s", vim.fn.stdpath('data'), sep, 'custom_config')
vim.fn.mkdir(config, 'p', '0o700')
local _ = io.open(string.format("%s%s%s", config, sep, "config.json"), "w+")
assert(_, "Unable to open custom config")
assert(_:close(), "Unable to close custom config")

-- Nothing like a good ole little bit of import path clobbering
-- ay Mr. Squidward?
package.path = custom_plugins_path .. "?.lua;" .. package.path
while true do
    local item, _ = vim.loop.fs_scandir_next(dir_handle)
    if not item then break end
    _ = item
    item = item:match('(.+)%.lua$')
    if not item then goto continue end
    if item:match('init') then
        goto continue
    end
    import(item)
    ::continue::
end

