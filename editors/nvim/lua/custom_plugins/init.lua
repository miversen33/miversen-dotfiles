local custom_plugins_path = vim.fn.stdpath('config') .. '/lua/custom_plugins/'
local dir_handle = vim.loop.fs_scandir(custom_plugins_path)
-- Nothing like a good ole little bit of import path clobbering
-- ay Mr. Squidward?
package.path = custom_plugins_path .. "?.lua;" .. package.path
while true do
    local item, _ = vim.loop.fs_scandir_next(dir_handle)
    if not item then break end
    item = item:match('(.+)%..+')
    if not item then goto continue end
    if item:match('^%s*$') or item:match('init') then
        goto continue
    end
    import(item)
    ::continue::
end

