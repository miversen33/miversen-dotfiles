-- lsps/lua.lua
---@class LuaLsp
---@field configured boolean Is lua configured yet?
---@field lsps table<string, Lsp> Lsps associated with lua

local M = {}

local uv = vim.loop or vim.uv
local jit = require("jit")
local architecture = jit.arch
local shell = require("scripts.shell")

local os_map = {
    Linux = 'linux',
    darwin = 'darwin',
    Windows = 'win32'
}

-- Declared at the bottom of this script. Deal with it
---@type LuaLsp
local lua = {}

-- We know its grumpy, the fields are declared below. Shut up
---@diagnostic disable-next-line: missing-fields
---@type Lsp
local emmy = {
    url =
    "https://github.com/EmmyLuaLs/emmylua-analyzer-rust/releases/download/${VERSION}/emmylua_ls-${OS}-${ARCH}.tar.gz",
    name = "emmylua_ls",
    enable = true,
    _latest_version = nil,
    _current_version = nil,
    pin = "0.10.0",
    ---@type vim.lsp.Config
    config = {
        cmd = { "$LSP_BIN", "--communication", "stdio" },
        filetypes = { "lua" },
        root_markers = { { ".luarc.json", ".luarc.jsonc", ".emmyrc.json" }, ".git" },
        -- We should _only_ do this if we are editing a neovim plugin or our neovim configuration...?
        cmd_env = { EMMYLUALS_CONFIG = string.format("%s/.emmyrc.json", vim.fn.stdpath('config')) }
    },
}

-- We know its grumpy, the fields are declared below. Shut up
---@diagnostic disable-next-line: missing-fields
---@type Lsp
local luals = {
    url =
    "https://github.com/LuaLS/lua-language-server/releases/download/${VERSION}/lua-language-server-${VERSION}-${OS}-${ARCH}.tar.gz",
    name = "lua_ls",
    enable = false,
    _latest_version = nil,
    _current_version = nil,
    pin = "3.15.0",
    ---@type vim.lsp.Config
    config = {
        cmd = { "$LSP_BIN" },
        filetypes = { "lua" },
        root_markers = { { ".luarc.json", ".luarc.jsonc", }, ".git" },
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT"
                }
            }
        },
    },
}

---------- Emmy LS

---@param ignore boolean? If provided, we will still return the proper path even if we aren't installed
---@return string The path to the binary. May be "MISSING BINARY" if the binary is not able to be located
function emmy.get_binary_path(ignore)
    local editor_dir = string.format("%s/miversen", vim.fn.stdpath("data"))
    local editor_lsp_dir = string.format("%s/lsps/lua/emmylua", editor_dir)
    if ignore or vim.fn.isdirectory(editor_lsp_dir) == 1 then
        return string.format("%s/emmylua_ls", editor_lsp_dir)
    else
        return "MISSING BINARY"
    end
end

function emmy.needs_install()
    return vim.fn.filereadable(emmy.get_binary_path()) ~= 1
end

-- Installs EmmyLuaLS
---@param success_callback fun() The function to call when install completes successfully
---@param error_callback fun(error: string, exit_code: number) The function to call when install fails
---@param opts LspInstallOpts? Options to use when installing
function emmy.install(success_callback, error_callback, opts)
    opts = opts or {}
    local force = opts.force or false
    local version = opts.version or emmy.version()
    local editor_lsp = emmy.get_binary_path(true)
    local editor_lsp_dir = vim.fs.dirname(editor_lsp)
    local temp_dir = string.format("%s/neovim_miversen_lsp_download-emmylua-%s", uv.os_tmpdir(),
        os.date("%Y%m%d%H%M%S"))

    if vim.fn.filereadable(editor_lsp) == 1 and not force then
        -- This lsp already exists, return
        success_callback()
        return
    end

    -- We should remove whatever was there before
    vim.fs.rm(editor_lsp, { recursive = true, force = true })
    -- Download the lsp
    vim.notify("Downloading emmy lua language server", vim.log.levels.DEBUG, {})
    vim.fs.mkdir(temp_dir, 'p')
    vim.fs.mkdir(editor_lsp_dir, 'p')

    local url = string.gsub(emmy.url, '${VERSION}', version)
    url = string.gsub(url, '${OS}', os_map[jit.os])
    url = string.gsub(url, '${ARCH}', architecture)
    local output_file = string.format("%s/emmylua-ls.tar.gz", temp_dir)
    vim.notify(string.format("Downloading emmylua ls from %s", url), vim.log.levels.DEBUG, {})

    local function extract_lsp()
        shell:new({ "tar", "-C", editor_lsp_dir, "-xzf", output_file }, {
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            ---@param result Shell.Serial
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = function(result)
                vim.fs.rm(temp_dir, { recursive = true, force = true })
                if result.exit_code ~= 0 then
                    -- Something awful happened!
                    error_callback(table.concat(result.stderr, " "), result.exit_code)
                    return
                end
                success_callback()
            end
        }):run()
    end

    local function download_lsp()
        shell:new({ "curl", "-fsS", "-L", url, "-o", output_file }, {
            ---@param result Shell.Serial
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = function(result)
                if result.exit_code ~= 0 then
                    -- Something awful happened!
                    error_callback(table.concat(result.stderr, " "), result.exit_code)
                    return
                end
                -- All gud
                extract_lsp()
            end,
            [shell.CONSTANTS.FLAGS.ASYNC] = true
        }):run()
    end

    download_lsp()
end

--Checks the current lua ls version and returns it
--NOTE: Will return -1 if it cannot find the lsp
---@return string
function emmy.version()
    if not emmy.needs_install() then
        emmy._current_version = nil
        return "-1"
    end
    if emmy._current_version then
        -- Lets used the cached version
        return emmy._current_version
    end
    local editor_lsp = emmy.get_binary_path()

    local emmy_ls_current_version = shell:new({ editor_lsp, "--version" }):run().stdout
    if not emmy_ls_current_version or #emmy_ls_current_version < 1 then
        emmy._current_version = nil
        return "-1"
    end
    emmy_ls_current_version = emmy_ls_current_version[1]:gsub("emmylua_ls ", "")
    if not emmy_ls_current_version then
        emmy._current_version = nil
        return "-1"
    else
        -- Lets cache the version so we can quickly pull it again without needing to shell out
        emmy._current_version = emmy_ls_current_version
        return emmy_ls_current_version
    end
end

---@param callback fun(version: string?)
function emmy.latest_version(callback)
    if emmy._latest_version then
        -- Lets use the cached version
        callback(emmy._latest_version)
        return
    end
    local emmy_ls_api = "https://api.github.com/repos/EmmyLuaLs/emmylua-analyzer-rust/releases/latest"
    ---@param result Shell.Serial
    local complete = function(result)
        local emmy_ls_latest_version
        if result.exit_code ~= 0 then
            emmy._latest_version = nil
            callback()
            -- Complain?
            return
        end
        local output = result.stdout
        for _, line in ipairs(output) do
            ---@type string
            match = line:match('^%s*"tag_name"%s*:.*')
            if match then
                -- lets pull the number out of the match
                version = match:gsub('^%s*"tag_name"%s*:%s*"', "")
                version = version:gsub('[",]+', '')
                emmy_ls_latest_version = version
            end
        end
        emmy._latest_version = emmy_ls_latest_version
        callback(emmy_ls_latest_version)
    end
    local handle = shell:new({ "curl", "-fsSL", emmy_ls_api },
        { [shell.CONSTANTS.FLAGS.ASYNC] = true, [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete }):run()
    if not handle then
        -- complain
        callback()
    end
    return
end

---@param callback fun(needs_update: boolean)
function emmy.needs_update(callback)
    -- If we aren't installed, we can't update
    if not emmy.needs_install() then
        callback(false)
        return
    end
    local current_version = emmy.version()
    ---@param latest_version string?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
        else
            callback(current_version < latest_version)
        end
    end
    emmy.latest_version(complete)
    return
end

---------- Lua LS

-- Installs Lua Language Server
---@param success_callback fun() The function to call when install completes successfully
---@param error_callback fun(error: string, exit_code: number) The function to call when install fails
---@param opts LspInstallOpts? Options to use when installing lua_ls
function luals.install(success_callback, error_callback, opts)
    opts = opts or {}
    local force = opts.force or false
    local version = opts.version or luals.latest_version()
    local editor_lsp = luals.get_binary_path(true)
    local editor_lsp_dir = vim.fs.dirname(vim.fs.dirname(editor_lsp))
    local temp_dir = string.format("%s/neovim_miversen_lsp_download-lua-%s", uv.os_tmpdir(),
        os.date("%Y%m%d%H%M%S"))

    if vim.fn.filereadable(editor_lsp) == 1 and not force then
        -- This lsp already exists, return
        success_callback()
        return
    end

    -- We should remove whatever was there before
    vim.fs.rm(editor_lsp, { recursive = true, force = true })
    -- Download the lsp
    vim.notify("Downloading lua language server", vim.log.levels.DEBUG, {})
    vim.fs.mkdir(temp_dir, 'p')
    vim.fs.mkdir(editor_lsp_dir, 'p')

    local url = string.gsub(luals.url, '${VERSION}', version)
    url = string.gsub(url, '${OS}', os_map[jit.os])
    url = string.gsub(url, '${ARCH}', architecture)
    local output_file = string.format("%s/lua-language-server.tar.gz", temp_dir)
    vim.notify(string.format("Downloading lua lsp from %s", url), vim.log.levels.DEBUG, {})

    local function extract_lsp()
        shell:new({ "tar", "-C", editor_lsp_dir, "-xzf", output_file }, {
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            ---@param result Shell.Serial
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = function(result)
                vim.fs.rm(temp_dir, { recursive = true, force = true })
                if result.exit_code ~= 0 then
                    -- Something awful happened!
                    error_callback(table.concat(result.stderr, " "), result.exit_code)
                    return
                end
                success_callback()
            end
        }):run()
    end

    local function download_lsp()
        shell:new({ "curl", "-fsS", "-L", url, "-o", output_file }, {
            ---@param result Shell.Serial
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = function(result)
                if result.exit_code ~= 0 then
                    -- Something awful happened!
                    error_callback(table.concat(result.stderr, " "), result.exit_code)
                    return
                end
                -- All gud
                extract_lsp()
            end,
            [shell.CONSTANTS.FLAGS.ASYNC] = true
        }):run()
    end

    download_lsp()
end

---@param ignore boolean If provided, we will still return the proper path even if we aren't installed
function luals.get_binary_path(ignore)
    local editor_dir = string.format("%s/miversen", vim.fn.stdpath("data"))
    local editor_lsp_dir = string.format("%s/lsps/lua/luals", editor_dir)
    if ignore or vim.fn.isdirectory(editor_lsp_dir) == 1 then
        return string.format("%s/bin/lua-language-server", editor_lsp_dir)
    else
        return "MISSING BINARY"
    end
end

function luals.needs_install()
    return vim.fn.filereadable(luals.get_binary_path()) ~= 1
end

--Checks the current lua ls version and returns it
--NOTE: Will return -1 if it cannot find the lsp
---@return string
function luals.version()
    if not luals.needs_install() then
        luals._current_version = nil
        return "-1"
    end
    if luals._current_version then
        -- Lets used the cached version
        return luals._current_version
    end
    local editor_lsp = luals.get_binary_path()

    local lua_ls_current_version = shell:new({ editor_lsp, "--version" }):run().stdout
    if not lua_ls_current_version or #lua_ls_current_version < 1 then
        luals._current_version = nil
        return "-1"
    end
    lua_ls_current_version = lua_ls_current_version[1]
    if not lua_ls_current_version then
        luals._current_version = nil
        return "-1"
    else
        -- Lets cache the version so we can quickly pull it again without needing to shell out
        luals._current_version = lua_ls_current_version
        return lua_ls_current_version
    end
end

---@param callback fun(version: string?)
function luals.latest_version(callback)
    if luals._latest_version then
        callback(luals._latest_version)
        return
    end
    local lua_ls_api = "https://api.github.com/repos/LuaLS/lua-language-server/releases/latest"
    ---@param result Shell.Serial
    local complete = function(result)
        local lua_ls_latest_version
        if result.exit_code ~= 0 then
            luals._latest_version = nil
            -- Complain?
            callback()
            return
        end
        local output = result.stdout
        for _, line in ipairs(output) do
            ---@type string
            match = line:match('^%s*"tag_name"%s*:.*')
            if match then
                -- lets pull the number out of the match
                version = match:gsub('^%s*"tag_name"%s*:%s*"', "")
                version = version:gsub('[",]+', '')
                lua_ls_latest_version = version
            end
        end
        luals._latest_version = lua_ls_latest_version
        callback(lua_ls_latest_version)
    end
    local handle = shell:new({ "curl", "-fsSL", lua_ls_api },
        { [shell.CONSTANTS.FLAGS.ASYNC] = true, [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete }):run()
    if not handle then
        -- complain?
        callback()
    end
end

---@param callback fun(needs_update: boolean)
function luals.needs_update(callback)
    -- If we aren't installed, we can't update
    if not luals.needs_install() then
        callback(false)
        return
    end
    local current_version = luals.version()
    ---@param latest_version string?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
        else
            callback(current_version < latest_version)
        end
    end
    luals.latest_version(complete)
end

return {
    emmy,
    luals
}
