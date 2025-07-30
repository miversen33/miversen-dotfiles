local uv = require('luv')

local M = {}
-- Creates directory {name}
---@param name string The directory to create
---@param flags string? Can contain the following character flags "p", "D", "R"
---  "p" creates intermediate directories as needed
---  "D" {name} will be deleted at the end of the current function, but _not_ recursively
---  "R" {name} will be recursively deleted at the end of the current function
---@param prot string? If provided, should set the directory and its children to these permissions. An example would be "rwxr-xr-x" (for user: read/write/execute, group: read/execute, all: read/execute)
function M.mkdir(name, flags, prot)
    flags = flags or ""
    
    -- Parse permission string to octal for mkdir
    local mode = prot and parse_permissions(prot) or 493 -- Default 0755
    
    -- Parse flags
    local create_parents = flags:find("p")
    local delete_recursive = flags:find("R")
    local delete_non_recursive = flags:find("D") and not delete_recursive -- R overrides D
    
    -- Build list of directories to create
    ---@type string[]
    local paths = {}
    if create_parents then
        for dir in vim.fs.parents(name) do
            table.insert(paths, dir)
        end
        table.insert(paths, name)
        -- Reverse to get proper creation order (deepest first)
        for i = 1, math.floor(#paths / 2) do
            paths[i], paths[#paths - i + 1] = paths[#paths - i + 1], paths[i]
        end
    else
        paths = { name }
    end
    -- Create each directory in the list
    for _, path in ipairs(paths) do
        local stat = uv.fs_stat(path)
        if not (stat and stat.type == 'directory') then
            local success, err = uv.fs_mkdir(path, mode)
            if not success and err ~= 'EEXIST' then
                error("Failed to create directory '" .. path .. "': " .. err)
            end
        end
    end
    
    -- Apply permissions to all created directories if specified
    if prot then
        for _, path in ipairs(paths) do
            pcall(M.chmod, path, prot) -- Ignore errors, just try our best
        end
    end
    
    -- Schedule cleanup if either D or R flag is present
    if delete_non_recursive or delete_recursive then
        vim.schedule(function()
            vim.fs.rm(name, {recursive = delete_recursive})
        end)
    end
end

-- Set the item permissions for {name} to {mode}
---@param name string The path (file/directory/socket/etc) to modify permissions of
---@param mode string The permissions to apply. An example, "rw-r-----" would mean user: read/write, group: read, all:
function M.chmod(name, mode)
    if #mode ~= 9 then
        error("Invalid permission format: " .. mode)
    end
    
    local octal_mode = 0
    local perms = {mode:sub(1,3), mode:sub(4,6), mode:sub(7,9)}
    local multipliers = {64, 8, 1} -- 8^2, 8^1, 8^0
    
    for i, perm in ipairs(perms) do
        local value = 0
        if perm:sub(1,1) == 'r' then value = value + 4 end
        if perm:sub(2,2) == 'w' then value = value + 2 end
        if perm:sub(3,3) == 'x' then value = value + 1 end
        octal_mode = octal_mode + (value * multipliers[i])
    end
    
    local success, err = uv.fs_chmod(name, octal_mode)
    if not success then
        error("Failed to set permissions on '" .. name .. "': " .. err)
    end
end

if not vim.fs.mkdir then
    vim.fs.mkdir = M.mkdir
end

if not vim.fs.chmod then
    vim.fs.chmod = M.chmod
end
