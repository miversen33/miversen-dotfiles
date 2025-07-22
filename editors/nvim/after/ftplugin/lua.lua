-- Check if the lua language server is in our path
local editor_config = vim.g._config
if not editor_config.languages then
    editor_config.languages = {}
end
if not editor_config.languages.lua then
    editor_config.languages.lua = {}
end

local lua = editor_config.languages.lua
if lua.configured then
    -- If we have already configured python, there is nothing else for us to do
    return
end

LUA_LSP_VERSION = "3.15.0"
LUA_LSP_URL = "https://github.com/LuaLS/lua-language-server/releases/download/${VERSION}/lua-language-server-${VERSION}-${OS}-${ARCH}.tar.gz"

local uv = vim.uv or vim.loop
local jit = require("jit")
local architecture = jit.arch
local shell = vim.g._config.shell

local os_map = {
    Linux = 'linux',
    darwin = 'darwin',
    Windows = 'win32'
}

local editor_dir = string.format("%s/miversen", vim.fn.stdpath("data"))
local editor_lsp_dir = string.format("%s/lsps/lua/", editor_dir)
local editor_lsp = string.format("%s/bin/lua-language-server", editor_lsp_dir)
local temp_dir = string.format("%s/neovim_miversen_lsp_download-lua-%s", uv.os_tmpdir(), vim.fn.strftime("%Y%m%d%H%M%S"))

local editor_lsp_config = {
    cmd = { editor_lsp },
    filetypes = { "lua" },
    root_markers = { { ".luarc.json", ".luarc.jsonc", }, ".git" },
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT"
            }
        }
    },
}

-- Execute command with proper error handling
---@param cmd string[] The command you want to run, split by whitespace
---@param callback fun()? The next function you want me to run. Only called if current function exits cleanly (exit code 0)
---@param error_callback fun(output: string, exit_code: number)? The function to call if there is an error
local function execute_command(cmd, callback, error_callback)
    local flags = shell.CONSTANTS.FLAGS
    ---@param _shell Shell.Serial
    local function exit_callback(_shell)
        if _shell.exit_code == 0 then
            if callback then
                callback()
            end
        elseif error_callback then
            error_callback(table.concat(_shell.stderr and _shell.stderr or {}, " "), _shell.exit_code)
        end
    end
    shell:new(
        cmd,
        {
            [flags.ASYNC] = true,
            [flags.EXIT_CALLBACK] = exit_callback
        }
    ):run()
end

local function main()
    if vim.fn.filereadable(editor_lsp) == 1 then
        -- lua lsp exists, lets just set it up
        vim.schedule(function()
            editor_config.lsp.activate("luals", editor_lsp_config)
        end)
        return
    end

    vim.notify("Downloading lua language server", vim.log.levels.DEBUG, {})
    vim.fn.mkdir(temp_dir, 'p')
    vim.fn.mkdir(editor_lsp_dir, 'p')

    local url = string.gsub(LUA_LSP_URL, '${VERSION}', LUA_LSP_VERSION)
    url = string.gsub(url, '${OS}', os_map[jit.os])
    url = string.gsub(url, '${ARCH}', architecture)
    local output_file = string.format("%s/lua-language-server.tar.gz", temp_dir)
    vim.notify(string.format("Downloading lua lsp from %s", url), vim.log.levels.DEBUG, {})

    local function extract_lsp()
        if not uv.fs_stat(output_file) then
            vim.notify("Lua lsp failed to download", vim.log.levels.WARNING, {})
            return
        end
        execute_command(
            {"tar", "-C", editor_lsp_dir, "-xzf", output_file},
            function()
                vim.schedule(function()
                    vim.fn.delete(temp_dir, 'rf')
                    editor_config.lsp.activate("luals", editor_config)
                end)
            end,
            function(error)
                vim.notify("Unable to extract lua langauge server", vim.log.levels.INFO, {})
                vim.notify(error, vim.log.levels.DEBUG, {})
            end
        )
    end

    execute_command({"curl", "-fsS", "-L", url, "-o", output_file}, extract_lsp, function(error)
        vim.notify("Unable to download lua language server", vim.log.levels.INFO, {})
        vim.notify(error, vim.log.levels.DEBUG, {})
    end)
end

main()

lua.configured = true
vim.g._config = editor_config

