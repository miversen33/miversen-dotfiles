---@class LuaLsp
---@field configured boolean Is lua configured yet?
---@field lsps table<string, Lsp> Lsps associated with lua

local M = {}

local LUA_LSP_URL =
"https://github.com/LuaLS/lua-language-server/releases/download/${VERSION}/lua-language-server-${VERSION}-${OS}-${ARCH}.tar.gz"
local EMMY_LSP_URL =
"https://github.com/EmmyLuaLs/emmylua-analyzer-rust/releases/download/${VERSION}/emmylua_ls-${OS}-${ARCH}.tar.gz"

local uv = vim.uv or vim.loop
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

---------- Emmy LS

---@param ignore boolean? If provided, we will still return the proper path even if we aren't installed
---@return string The path to the binary. May be "MISSING BINARY" if the binary is not able to be located
function M.emmylua_ls_get_binary_path(ignore)
    local editor_dir = string.format("%s/miversen", vim.fn.stdpath("data"))
    local editor_lsp_dir = string.format("%s/lsps/lua/emmylua", editor_dir)
    if ignore or vim.fn.isdirectory(editor_lsp_dir) == 1 then
        return string.format("%s/emmylua_ls", editor_lsp_dir)
    else
        return "MISSING BINARY"
    end
end

function M.is_emmylua_ls_installed()
    return vim.fn.filereadable(M.emmylua_ls_get_binary_path()) == 1
end

-- Installs EmmyLuaLS
---@param success_callback fun() The function to call when install completes successfully
---@param error_callback fun(error: string, exit_code: number) The function to call when install fails
---@param opts LspInstallOpts? Options to use when installing
function M.install_emmyls(success_callback, error_callback, opts)
    opts = opts or {}
    local force = opts.force or false
    local version = opts.version or M.get_current_emmylua_ls_version()
    local editor_lsp = M.emmylua_ls_get_binary_path(true)
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

    local url = string.gsub(EMMY_LSP_URL, '${VERSION}', version)
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
function M.get_current_emmylua_ls_version()
    if not M.is_emmylua_ls_installed() then
        lua.lsps.emmylua_ls._current_version = nil
        return "-1"
    end
    if lua.lsps.emmylua_ls._current_version then
        -- Lets used the cached version
        return lua.lsps.emmylua_ls._current_version
    end
    local editor_lsp = M.emmylua_ls_get_binary_path()

    local emmy_ls_current_version = shell:new({ editor_lsp, "--version" }):run().stdout
    if not emmy_ls_current_version or #emmy_ls_current_version < 1 then
        lua.lsps.emmylua_ls._current_version = nil
        return "-1"
    end
    emmy_ls_current_version = emmy_ls_current_version[1]:gsub("emmylua_ls ", "")
    if not emmy_ls_current_version then
        lua.lsps.emmylua_ls._current_version = nil
        return "-1"
    else
        -- Lets cache the version so we can quickly pull it again without needing to shell out
        lua.lsps.emmylua_ls._current_version = emmy_ls_current_version
        return emmy_ls_current_version
    end
end

---@param callback fun(version: string?)
function M.get_latest_emmylua_ls_version(callback)
    if lua.lsps.emmylua_ls._latest_version then
        -- Lets use the cached version
        callback(lua.lsps.emmylua_ls._latest_version)
        return
    end
    local emmy_ls_api = "https://api.github.com/repos/EmmyLuaLs/emmylua-analyzer-rust/releases/latest"
    ---@param result Shell.Serial
    local complete = function(result)
        local emmy_ls_latest_version
        if result.exit_code ~= 0 then
            lua.lsps.emmylua_ls._latest_version = nil
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
        lua.lsps.emmylua_ls._latest_version = emmy_ls_latest_version
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
function M.does_emmylua_ls_need_update(callback)
    -- If we aren't installed, we can't update
    if not M.is_emmylua_ls_installed() then
        callback(false)
        return
    end
    local current_version = M.get_current_emmylua_ls_version()
    ---@param latest_version string?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
        else
            callback(current_version < latest_version)
        end
    end
    M.get_latest_emmylua_ls_version(complete)
    return
end

---------- Lua LS

-- Installs Lua Language Server
---@param success_callback fun() The function to call when install completes successfully
---@param error_callback fun(error: string, exit_code: number) The function to call when install fails
---@param opts LspInstallOpts? Options to use when installing lua_ls
function M.install_luals(success_callback, error_callback, opts)
    opts = opts or {}
    local force = opts.force or false
    local version = opts.version or M.get_latest_lua_ls_version()
    local editor_lsp = M.lua_ls_get_binary_path(true)
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

    local url = string.gsub(LUA_LSP_URL, '${VERSION}', version)
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
function M.lua_ls_get_binary_path(ignore)
    local editor_dir = string.format("%s/miversen", vim.fn.stdpath("data"))
    local editor_lsp_dir = string.format("%s/lsps/lua/luals", editor_dir)
    if ignore or vim.fn.isdirectory(editor_lsp_dir) == 1 then
        return string.format("%s/bin/lua-language-server", editor_lsp_dir)
    else
        return "MISSING BINARY"
    end
end

function M.is_lua_ls_installed()
    return vim.fn.filereadable(M.lua_ls_get_binary_path()) == 1
end

--Checks the current lua ls version and returns it
--NOTE: Will return -1 if it cannot find the lsp
---@return string
function M.get_current_lua_ls_version()
    if not M.is_lua_ls_installed() then
        lua.lsps.lua_ls._current_version = nil
        return "-1"
    end
    if lua.lsps.lua_ls._current_version then
        -- Lets used the cached version
        return lua.lsps.lua_ls._current_version
    end
    local editor_lsp = M.lua_ls_get_binary_path()

    local lua_ls_current_version = shell:new({ editor_lsp, "--version" }):run().stdout
    if not lua_ls_current_version or #lua_ls_current_version < 1 then
        lua.lsps.lua_ls._current_version = nil
        return "-1"
    end
    lua_ls_current_version = lua_ls_current_version[1]
    if not lua_ls_current_version then
        lua.lsps.lua_ls._current_version = nil
        return "-1"
    else
        -- Lets cache the version so we can quickly pull it again without needing to shell out
        lua.lsps.lua_ls._current_version = lua_ls_current_version
        return lua_ls_current_version
    end
end

---@param callback fun(version: string?)
function M.get_latest_lua_ls_version(callback)
    if lua.lsps.lua_ls._latest_version then
        callback(lua.lsps.lua_ls._latest_version)
        return
    end
    local lua_ls_api = "https://api.github.com/repos/LuaLS/lua-language-server/releases/latest"
    ---@param result Shell.Serial
    local complete = function(result)
        local lua_ls_latest_version
        if result.exit_code ~= 0 then
            lua.lsps.lua_ls._latest_version = nil
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
        lua.lsps.lua_ls._latest_version = lua_ls_latest_version
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
function M.does_lua_ls_need_update(callback)
    -- If we aren't installed, we can't update
    if not M.is_lua_ls_installed() then
        callback(false)
        return
    end
    local current_version = M.get_current_lua_ls_version()
    ---@param latest_version string?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
        else
            callback(current_version < latest_version)
        end
    end
    M.get_latest_lua_ls_version(complete)
end

-----------------------------------------------------------------------------------------------------
--============================================ INIT ===============================================--
-----------------------------------------------------------------------------------------------------

-- Check if the lua language server is in our path
local editor_config = vim.g._config
if not editor_config.languages then
    editor_config.languages = {}
end
if not editor_config.languages.lua then
    ---@type LuaLsp
    editor_config.languages.lua = {
        configured = false,
        ---@type Lsp[]
        lsps = {
            lua_ls = {
                name = "lua_ls",
                enable = false,
                pin = "3.15.0",
                version = M.get_current_lua_ls_version,
                latest_version = M.get_latest_lua_ls_version,
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
                get_binary_path = M.lua_ls_get_binary_path,
                install = function(s, e, opts) M.install_luals(s, e, opts) end,
                needs_install = function() return not M.is_lua_ls_installed() end,
                needs_update = M.does_lua_ls_need_update
            },
            ---@type Lsp
            emmylua_ls = {
                name = "emmylua_ls",
                enable = true,
                pin = "0.10.0",
                version = M.get_current_emmylua_ls_version,
                latest_version = M.get_latest_emmylua_ls_version,
                ---@type vim.lsp.Config
                config = {
                    cmd = { "$LSP_BIN", "--communication", "stdio" },
                    filetypes = { "lua" },
                    root_markers = { { ".luarc.json", ".luarc.jsonc", ".emmyrc.json" }, ".git" },
                    -- We should _only_ do this if we are editing a neovim plugin or our neovim configuration...?
                    cmd_env = { EMMYLUALS_CONFIG = string.format("%s/.emmyrc.json", vim.fn.stdpath('config')) }
                },
                get_binary_path = M.emmylua_ls_get_binary_path,
                install = function(s, e, opts) M.install_emmyls(s, e, opts) end,
                needs_install = function() return not M.is_emmylua_ls_installed() end,
                needs_update = M.does_emmylua_ls_need_update
            }
        }
    }
end

lua = editor_config.languages.lua
if lua.configured then
    -- If we have already configured lua, there is nothing else for us to do
    return
end

local lsp = require('scripts.lsp')
for _, lua_lsp in pairs(lua.lsps) do
    lsp.register("lua", lua_lsp)
end

lua.configured = true
vim.g._config = editor_config
