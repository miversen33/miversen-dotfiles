-- lsps/markdown.lua

local uv = vim.loop or vim.uv
local jit = require("jit")
local architecture = jit.arch
local shell = require("scripts.shell")

local os_map = {
    Linux = 'linux',
    darwin = 'darwin',
    Windows = 'win32'
}

---@type Lsp
local marksman = {
    url = "https://github.com/artempyanykh/marksman/releases/download/${VERSION}/marksman-${OS}-${ARCH}",
    name = "marksman",
    pin = "2024-12-18",
    _latest_version = nil,
    _current_version = nil,
    config = {
        cmd = { "$LSP_BIN", "server" },
        filetypes = { "markdown" }
    }
}

---@param ignore boolean? If provided, we will still return the proper path even if we aren't installed
---@return string The path to the binary. May be "MISSING BINARY" if the binary is not able to be located
function marksman.get_binary_path(ignore)
    local editor_dir = string.format("%s/miversen", vim.fn.stdpath("data"))
    local editor_lsp = string.format("%s/lsps/markdown/marksman", editor_dir)
    if ignore or vim.fn.filereadable(editor_lsp) == 1 then
        return editor_lsp
    else
        return "MISSING BINARY"
    end
end

---@return boolean
function marksman.needs_install()
    return vim.fn.filereadable(marksman.get_binary_path()) ~= 1
end

---@param callback fun(needs_update: boolean)
function marksman.needs_update(callback)
    if not marksman.needs_install() then
        callback(false)
        return
    end
    local current_version = marksman.version()
    ---@param latest_version string?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
        else
            callback(current_version < latest_version)
        end
    end
    marksman.latest_version(complete)
end

-- Gets the version of the currently installed marksman binary
-- NOTE: Will return "-1" if it cannot find the lsp
---@return string
function marksman.version()
    if not marksman.needs_install() then
        marksman._current_version = nil
        return "-1"
    end
    if marksman._current_version then
        return marksman._current_version
    end
    local editor_lsp = marksman.get_binary_path()
    local marksman_current_version = shell:new({ editor_lsp, "--version" }):run().stdout
    if not marksman_current_version or #marksman_current_version < 1 then
        marksman._current_version = nil
        return "-1"
    end
    marksman_current_version = marksman_current_version[1]:gsub('marksman version ', ""):gsub('(.*$', '')
    if not marksman_current_version then
        marksman._current_version = nil
        return "-1"
    else
        marksman._current_version = marksman_current_version
        return marksman_current_version
    end
end

-- Gets the most recent version of marksman from github
---@param callback fun(version: string?)
function marksman.latest_version(callback)
    callback("-1")
    -- if marksman._latest_version then
    --     callback(marksman._latest_version)
    --     return
    -- end
    -- local marksman_api = "https://api.github.com/repos/artempyanykh/marksman/releases/latest"
    -- ---@param result Shell.Serial
    -- local complete = function(result)
    --     if not result or result.exit_code ~= 0 then
    --         -- complain
    --         callback()
    --         return
    --     end
    --     local version = vim.json.decode(result.stdout)
    --     if not version then
    --         callback()
    --         return
    --     end
    --     marksman._current_version = version.tag_name
    --     callback(version.tag_name)
    --     return
    -- end
    -- local handle = shell:new({ "curl", "-fsSL", marksman_api }, {
    --     [shell.CONSTANTS.FLAGS.ASYNC] = true,
    --     [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete,
    --     [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = ""
    -- }):run()
    -- if not handle then
    --     -- complain
    --     callback()
    -- end
    -- return
end

-- Installs marksman
---@param success_callback fun() The function to call when install completes succesfully
---@param error_callback fun(error: string, exit_code: number?) The function to call when install fails
---@param opts LspInstallOpts? Options to use when installing
function marksman.install(success_callback, error_callback, opts)
    opts = opts or {}
    local force = opts.force or false
    local editor_lsp = marksman.get_binary_path(true)
    local editor_lsp_dir = vim.fs.dirname(editor_lsp)
    local temp_dir = string.format("%s/neovim_miversen_lsp_download_marksman-%s", uv.os_tmpdir(), os.date("%Y%m%d%H%M%S"))

    if vim.fn.filereadable(editor_lsp) == 1 and not force then
        success_callback()
        return
    end


    vim.fs.rm(editor_lsp, { recursive = true, force = true })
    vim.notify("Downloading marksman language server", vim.log.levels.DEBUG, {})
    vim.fs.mkdir(temp_dir, 'p')
    vim.fs.mkdir(editor_lsp_dir, 'p')

    local url = string.gsub(marksman.url, "${OS}", os_map[jit.os])
    url = url:gsub("${ARCH}", jit.arch)

    local cleanup = function()
        vim.fs.rm(temp_dir, { recursive = true, force = true })
    end

    ---@param result Shell.Serial
    local _chmod_lsp = function(result)
        if not result or result.exit_code ~= 0 then
            cleanup()
            error_callback("Unable to download marksman lsp", result.exit_code and result.exit_code or -1)
            return
        end
        vim.fs.chmod(editor_lsp, "rwxr-xr-x")
        cleanup()
        success_callback()
    end

    ---@param version string?
    local _download_lsp = function(version)
        if not version then
            cleanup()
            error_callback("No version found to install marksman", -1)
            return
        end
        vim.notify(string.format("Downloading marksman version %s", version), vim.log.levels.DEBUG)
        local _url = url:gsub("${VERSION}", version)
        vim.notify(string.format("Downloading marksman from %s", _url), vim.log.levels.DEBUG)
        local handle = shell:new({ "curl", "-fsSL", _url, "-o", editor_lsp }, {
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = _chmod_lsp
        }):run()
        if not handle then
            cleanup()
            error_callback("Unable to download marksman language server", -1)
            return
        end
    end

    if opts.version then
        _download_lsp(opts.version)
    else
        marksman.latest_version(_download_lsp)
    end
end

return {
    marksman
}
