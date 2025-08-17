-- lsps/c.lua

local uv = vim.uv or vim.loop
local jit = require("jit")
local shell = require("scripts.shell")

local os_map = {
    Linux = 'linux',
    OSX = 'mac',
    Windows = 'windows'
}

---@type Lsp
local clangd = {
    url = "https://github.com/clangd/clangd/releases/download/${VERSION}/clangd-${OS}-${VERSION}.zip",
    name = "clangd",
    _latest_version = nil,
    _current_version = nil,
    ---@type vim.lsp.Config
    config = {
        cmd = { "$LSP_BIN" },
        filetypes = { "c", "cpp" }
    }
}

---@param ignore boolean? If provided (and true), we will still return the proper path even if we aren't installed yet
---@return string The path to the binary. May be "MISSING BINARY" if the binary is not able to be located
function clangd.get_binary_path(ignore)
    local editor_dir = string.format("%s/miversen", vim.fn.stdpath("data"))
    local editor_lsp_dir = string.format("%s/lsps/c/clangd", editor_dir)
    if ignore or vim.fn.isdirectory(editor_lsp_dir) == 1 then
        return string.format("%s/bin/clangd", editor_lsp_dir)
    else
        return "MISSING BINARY"
    end
end

---@return boolean A true/false on if clangd is installed
function clangd.needs_install()
    return vim.fn.filereadable(clangd.get_binary_path()) ~= 1
end

---@param callback fun(needs_update: boolean)
function clangd.needs_update(callback)
    if not clangd.needs_install() then
        callback(false)
        return
    end
    local current_version = clangd.version()
    ---@param latest_version string?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
        else
            callback(current_version < latest_version)
        end
    end
    clangd.latest_version(complete)
end

-- Gets the version of the currently installed clangd binary
-- NOTE: Will return "-1" if it cannot find the lsp
---@return string
function clangd.version()
    if not clangd.needs_install() then
        clangd._current_version = nil
        return "-1"
    end
    if clangd._current_version then
        return clangd._current_version
    end
    local editor_lsp = clangd.get_binary_path()
    local clangd_current_version = shell:new({ editor_lsp, "--version" }):run().stdout
    if not clangd_current_version or #clangd_current_version < 1 then
        clangd._current_version = nil
        return "-1"
    end
    clangd_current_version = clangd_current_version[1]:gsub('clangd version ', ""):gsub('(.*$', '')
    if not clangd_current_version then
        clangd._current_version = nil
        return "-1"
    else
        clangd._current_version = clangd_current_version
        return clangd_current_version
    end
end

-- Gets the most recent version of clangd from github
---@param callback fun(version: string?)
function clangd.latest_version(callback)
    if clangd._latest_version then
        callback(clangd._latest_version)
        return
    end
    local clangd_api = "https://api.github.com/repos/clangd/clangd/releases/latest"
    ---@param result Shell.Serial
    local complete = function(result)
        if not result or result.exit_code ~= 0 then
            -- complain
            callback()
            return
        end
        local version = vim.json.decode(result.stdout)
        if not version then
            callback()
            return
        end
        clangd._current_version = version.tag_name
        callback(version.tag_name)
        return
    end
    local handle = shell:new({ "curl", "-fsSL", clangd_api }, {
        [shell.CONSTANTS.FLAGS.ASYNC] = true,
        [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete,
        [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = ""
    }):run()
    if not handle then
        -- complain
        callback()
    end
    return
end

-- Installs clangd
---@param success_callback fun() The function to call when install completes succesfully
---@param error_callback fun(error: string, exit_code: number?) The function to call when install fails
---@param opts LspInstallOpts? Options to use when installing
function clangd.install(success_callback, error_callback, opts)
    opts = opts or {}
    local force = opts.force or false
    local editor_lsp = clangd.get_binary_path(true)
    local editor_lsp_dir = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(editor_lsp)))
    local temp_dir = string.format("%s/neovim_miversen_lsp_download_clangd-%s", uv.os_tmpdir(), os.date("%Y%m%d%H%M%S"))

    if vim.fn.filereadable(editor_lsp) == 1 and not force then
        success_callback()
        return
    end

    vim.fs.rm(editor_lsp, { recursive = true, force = true })
    vim.notify("Downloading clangd language server", vim.log.levels.DEBUG, {})
    vim.fs.mkdir(temp_dir, 'p')
    vim.fs.mkdir(editor_lsp_dir, 'p')
    local output_file = string.format("%s/%s", temp_dir, "clangd.zip")

    local url = string.gsub(clangd.url, "${OS}", os_map[jit.os])

    local cleanup = function()
        vim.fs.rm(temp_dir, { recursive = true, force = true })
    end

    ---@param result Shell.Serial
    local _place_lsp = function(result)
        if not result or result.exit_code ~= 0 then
            cleanup()
            error_callback("Unable to extract clangd lsp", result.exit_code and result.exit_code or -1)
            return
        end
        -- Lets find the directory we just extracted
        local clang_dir = nil
        for item in vim.fs.dir(temp_dir) do
            if item:match('clangd_') then
                clang_dir = item
                break
            end
        end
        if not clang_dir then
            cleanup()
            error_callback("Unable to locate extracted clangd lsp", -1)
        end
        vim.fs.mv(string.format("%s/%s", temp_dir, clang_dir), string.format("%s/clangd", editor_lsp_dir))
        cleanup()
        success_callback()
    end

    ---@param result Shell.Serial
    local _extract_lsp = function(result)
        if not result or result.exit_code ~= 0 then
            cleanup()
            error_callback("Unable to download clangd lsp", result.exit_code and result.exit_code or -1)
        end
        -- This only works on linux...
        local handle = shell:new({ "unzip", "-d", temp_dir, output_file }, {
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = _place_lsp
        }):run()
        if not handle then
            cleanup()
            error_callback("Unable to extract clangd lsp", -1)
        end
    end

    ---@param version string?
    local _download_lsp = function(version)
        if not version then
            cleanup()
            error_callback("No version found to install clangd", -1)
            return
        end
        vim.notify(string.format("Downloading clangd version %s", version), vim.log.levels.DEBUG)
        local _url = url:gsub("${VERSION}", version)
        vim.notify(string.format("Downloading clangd from %s", _url), vim.log.levels.DEBUG)
        local handle = shell:new({ "curl", "-fsSL", _url, "-o", output_file }, {
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = _extract_lsp
        }):run()
        if not handle then
            cleanup()
            error_callback("Unable to download clangd language server", -1)
            return
        end
    end

    if opts.version then
        _download_lsp(opts.version)
    else
        clangd.latest_version(_download_lsp)
    end
end

return {
    clangd
}
