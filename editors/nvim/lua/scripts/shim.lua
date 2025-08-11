local uv = require('luv')

local M = {}

-- Find the first parent directory containing a specific "marker"
---@param source string File path (absolute or relative) to begin the search from
---@param marker string|string[]|fun(name: string, path: string): boolean A marker, or list of markers, to search for
---@return string? Directory path containing one of the given markers, or nil if no directory was found
function M.root(source, marker)
    -- Convert relative path to absolute if needed
    local start_path = source
    if not start_path:match("^/") and not start_path:match("^%a:") then -- Unix absolute or Windows drive
        start_path = uv.fs_realpath(source) or (uv.cwd() .. "/" .. source)
    end

    -- Determine marker type and create checker function
    local check_marker
    if type(marker) == "function" then
        check_marker = marker
    elseif type(marker) == "string" then
        check_marker = function(name)
            return name == marker
        end
    elseif type(marker) == "table" then
        check_marker = function(name)
            for _, m in ipairs(marker) do
                if name == m then
                    return true
                end
            end
            return false
        end
    else
        error("Invalid marker type: " .. type(marker))
    end

    -- Search up the directory tree
    for dir in vim.fs.parents(start_path) do
        local handle = uv.fs_scandir(dir)
        if handle then
            while true do
                local name, _ = uv.fs_scandir_next(handle)
                if not name then break end

                if check_marker(name, dir .. "/" .. name) then
                    return dir
                end
            end
        end
    end

    return nil
end

-- Copy files or directories
---@param from string The source path to copy from
---@param to string The destination path to copy to
---@param opts table<string, boolean>? A table of options to provide. Valid options are
---    recursive: Copy directories and their contents recursively
---    preserve: Preserve file attributes (permissions, timestamps)
---    force: Overwrite existing files without prompting
function M.cp(from, to, opts)
    opts = opts or {}
    local recursive = opts.recursive or false
    local preserve = opts.preserve or false
    local force = opts.force or false

    local from_stat = uv.fs_stat(from)
    if not from_stat then
        error("Source path does not exist: " .. from)
    end

    -- Check if destination exists and handle force flag
    local to_stat = uv.fs_stat(to)
    if to_stat and not force then
        error("Destination exists: " .. to .. " (use force option to overwrite)")
    end

    if from_stat.type == "directory" then
        if not recursive then
            error("Cannot copy directory '" .. from .. "' without recursive option")
        end
        M._copy_directory(from, to, from_stat, preserve)
    else
        -- Handle other types (symlinks, etc.)
        M._copy_file(from, to, from_stat, preserve)
    end
end

-- Helper function to copy a symlink
function M._copy_symlink(from, to, preserve)
    local target = uv.fs_readlink(from)
    if not target then
        error("Failed to read symlink: " .. from)
    end

    local success, err = uv.fs_symlink(target, to)
    if not success then
        error("Failed to create symlink '" .. to .. "' -> '" .. target .. "': " .. err)
    end

    if preserve then
        -- Preserve symlink timestamps (using lstat since we don't want to follow the link)
        local lstat = uv.fs_lstat(from)
        if lstat then
            pcall(uv.fs_lutime, to, lstat.atime.sec, lstat.mtime.sec) -- lutime for symlinks
        end
    end
end

-- Helper function to copy a single file
function M._copy_file(from, to, from_stat, preserve)
    local success, err = uv.fs_copyfile(from, to)
    if not success then
        error("Failed to copy file '" .. from .. "' to '" .. to .. "': " .. err)
    end

    if preserve and from_stat then
        -- Preserve permissions
        pcall(uv.fs_chmod, to, from_stat.mode)
        -- Preserve timestamps
        pcall(uv.fs_utime, to, from_stat.atime.sec, from_stat.mtime.sec)
    end
end

-- Helper function to copy a directory recursively
function M._copy_directory(from, to, from_stat, preserve)
    -- Create target directory
    local mode = from_stat and from_stat.mode or 493 -- Default 0755
    local success, err = uv.fs_mkdir(to, mode)
    if not success and err ~= "EEXIST" then
        error("Failed to create directory '" .. to .. "': " .. err)
    end

    if preserve and from_stat then
        -- Preserve directory timestamps
        pcall(uv.fs_utime, to, from_stat.atime.sec, from_stat.mtime.sec)
    end

    -- Copy directory contents
    local handle = uv.fs_scandir(from)
    if handle then
        while true do
            local name, type = uv.fs_scandir_next(handle)
            if not name then break end

            local from_path = from .. "/" .. name
            local to_path = to .. "/" .. name
            local _stat = preserve and uv.fs_stat(from_path) or nil

            if type == "link" then
                M._copy_symlink(from_path, to_path, preserve)
            elseif type == "directory" then
                M._copy_directory(from_path, to_path, _stat, preserve)
            else
                M._copy_file(from_path, to_path, _stat, preserve)
            end
        end
    end
end

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
    local paths = { name }
    if create_parents then
        for dir in vim.fs.parents(name) do
            table.insert(paths, dir)
        end
        -- Reverse to get proper creation order (deepest first)
        for i = 1, math.floor(#paths / 2) do
            paths[i], paths[#paths - i + 1] = paths[#paths - i + 1], paths[i]
        end
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
            vim.fs.rm(name, { recursive = delete_recursive })
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
    local perms = { mode:sub(1, 3), mode:sub(4, 6), mode:sub(7, 9) }
    local multipliers = { 64, 8, 1 } -- 8^2, 8^1, 8^0

    for i, perm in ipairs(perms) do
        local value = 0
        if perm:sub(1, 1) == 'r' then value = value + 4 end
        if perm:sub(2, 2) == 'w' then value = value + 2 end
        if perm:sub(3, 3) == 'x' then value = value + 1 end
        octal_mode = octal_mode + (value * multipliers[i])
    end

    local success, err = uv.fs_chmod(name, octal_mode)
    if not success then
        error("Failed to set permissions on '" .. name .. "': " .. err)
    end
end

-- Moves {from} to {to}
---@param from string An item (file/directory/socket/etc) to be moved
---@param to string The target location to move to
function M.mv(from, to)
    ---@type string
    local success
    ---@type string
    local err
    success, err = uv.fs_rename(from, to)
    if not success then
        if err:match('^EXDEV') then
            -- Cross-device move: fall back to copy + delete
            M.cp(from, to, { recursive = true, preserve = true })
            vim.fs.rm(from, { recursive = true })
        else
            error("Failed to move '" .. from .. "' to '" .. to .. "': " .. err)
        end
    end
end

if not vim.fs.mkdir then
    vim.fs.mkdir = M.mkdir
end

if not vim.fs.chmod then
    vim.fs.chmod = M.chmod
end

if not vim.fs.mv then
    vim.fs.mv = M.mv
end

if not vim.fs.safe_root then
    vim.fs.safe_root = M.root
end
