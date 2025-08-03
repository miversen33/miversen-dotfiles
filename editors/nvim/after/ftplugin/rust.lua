---@class Rust
---@field configured boolean Is rust configured yet?
---@field lsps table<string, Lsp> Lsps associated with rust

---@class RustVersion
---@field release string The release version per github api
---@field semantic string The version per the binary.

local M = {}

local RUST_ANALYZER_URL =
"https://github.com/rust-lang/rust-analyzer/releases/download/${VERSION}/rust-analyzer-x86_64-${OS}"

local uv = vim.uv or vim.loop
local jit = require("jit")
local shell = require("scripts.shell")

local os_map = {
    Linux = 'unknown-linux-gnu.gz',
    darwin = 'apple-darwin.gz',
    Windows = 'pc-windows-msvc.zip'
}



-- Declared at the bottom of this script. Deal with it
---@type Rust
local rust = {}

---@param ignore boolean? If provided, we will still return the proper path even if we aren't installed
---@return string The path to the bianry. May be "MISSING BINARY" if the binary is not able to be located
function M.rust_analyzer_get_binary_path(ignore)
    local editor_dir = string.format("%s/miversen", vim.fn.stdpath("data"))
    local editor_lsp_dir = string.format("%s/lsps/rust/rust-analyzer", editor_dir)
    if ignore or vim.fn.isdirectory(editor_lsp_dir) == 1 then
        return string.format("%s/rust-analyzer", editor_lsp_dir)
    else
        return "MISSING BINARY"
    end
end

---@return boolean A true/false on if rust_analyzer is installed
function M.is_rust_analyzer_installed()
    return vim.fn.filereadable(M.rust_analyzer_get_binary_path()) == 1
end

-- Gets the version of the currently installed rust_analyzer
-- NOTE: Will return "-1" if it cannot find the lsp
---@return string
function M.get_current_rust_analyzer_version()
    if not M.is_rust_analyzer_installed() then
        rust.lsps.rust_analyzer._current_version = nil
        return "-1"
    end
    if rust.lsps.rust_analyzer._current_version then
        return rust.lsps.rust_analyzer._current_version
    end
    local editor_lsp = M.rust_analyzer_get_binary_path()

    local rust_analyzer_current_version = shell:new({ editor_lsp, "--version" }):run().stdout
    if not rust_analyzer_current_version or #rust_analyzer_current_version < 1 then
        rust.lsps.rust_analyzer._current_version = nil
        return "-1"
    end
    rust_analyzer_current_version = rust_analyzer_current_version[1]:gsub("rust-analyzer ", "")
    if not rust_analyzer_current_version then
        rust.lsps.rust_analyzer._current_version = nil
        return "-1"
    else
        rust.lsps.rust_analyzer._current_version = rust_analyzer_current_version
        return rust_analyzer_current_version
    end
end

---@param callback fun(version: RustVersion?)
function M._get_latest_rust_analyzer_version(callback)
    if rust.lsps.rust_analyzer._latest_version then
        callback(rust.lsps.rust_analyzer._latest_version)
        return
    end

    local rust_anaylzer_api = "https://api.github.com/repos/rust-lang/rust-analyzer/releases/latest"

    ---@param result Shell.Serial
    local complete = function(result)
        if result.exit_code ~= 0 then
            rust.lsps.rust_analyzer._latest_version = nil
            -- Complain
            callback({
                release = "-1",
                semantic = "-1"
            })
            return
        end
        local output = vim.json.decode(result.stdout)
        if not output or not next(output) then
            rust.lsps.rust_analyzer._latest_version = nil
            callback({
                release = "-1",
                semantic = "-1"
            })
            return
        end
        local semantic_version = output.body:match("Release:.-%(`v(%d+%.%d+%.%d+)`%)")
        local release_version = output.tag_name
        if not semantic_version or not release_version then
            rust.lsps.rust_analyzer._latest_version = nil
            callback({
                release = "-1",
                semantic = "-1"
            })
            return
        end
        rust.lsps.rust_analyzer._latest_version = {
            release = release_version,
            semantic = semantic_version
        }
        callback(rust.lsps.rust_analyzer._latest_version)
        return
    end
    local handle = shell:new(
        { "curl", "-fsSL", rust_anaylzer_api },
        {
            [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = "",
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete
        }
    ):run()
    if not handle then
        -- Complain?
        callback()
        return
    end
end

-- Gets the most recent version of rust_analyzer from github
---@param callback fun(version: string?)
function M.get_latest_rust_analyzer_version(callback)
    ---@param version RustVersion?
    local complete = function(version)
        callback(version.release)
    end
    M._get_latest_rust_analyzer_version(complete)
end

-- Checks to see if we need an update
---@param callback fun(needs_update: boolean?)
function M.rust_analyzer_needs_update(callback)
    local current_version = M.get_current_rust_analyzer_version()
    ---@param latest_version string?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
            return
        end
        callback(latest_version > current_version)
        return
    end
    M.get_latest_rust_analyzer_version(complete)
end

-- Installs Rust Analyzer
---@param success_callback fun() The function to call when install completes successfully
---@param error_callback fun(error: string, exit_code: number) The function to call when install fails
---@param opts LspInstallOpts? Options to use when installing
function M.install_rust_analyzer(success_callback, error_callback, opts)
    opts = opts or {}
    local force = opts.force or false
    local version = opts.version or M._get_latest_rust_analyzer_version().release
    local editor_lsp = M.rust_analyzer_get_binary_path(true)
    local editor_lsp_dir = vim.fs.dirname(editor_lsp)
    local temp_dir = string.format("%s/neovim_miversen_lsp_download-rust-analyzer-%s", uv.os_tmpdir(),
        os.date("%Y%m%d%H%M%S"))

    if vim.fn.filereadable(editor_lsp) == 1 and not force then
        -- This lsp already exists, return
        success_callback()
        return
    end

    -- We should remove whatever was there before
    vim.fs.rm(editor_lsp, { recursive = true, force = true })
    -- Download the lsp
    vim.notify("Downloading rust-analyzer language server", vim.log.levels.DEBUG, {})
    vim.fs.mkdir(temp_dir, 'p')
    vim.fs.mkdir(editor_lsp_dir, 'p')

    local url = string.gsub(RUST_ANALYZER_URL, '${VERSION}', version)
    url = string.gsub(url, '${OS}', os_map[jit.os])
    local output_file = string.format("%s/rust-analyzer.gz", temp_dir)
    vim.notify(string.format("Downloading rust-analyzer from %s", url), vim.log.levels.DEBUG, {})

    local function extract_lsp()
        -- This will not work with windows
        shell:new({ "gzip", "-d", output_file }, {
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            ---@param result Shell.Serial
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = function(result)
                if result.exit_code ~= 0 then
                    -- Something awful happened!
                    error_callback(table.concat(result.stderr, " "), result.exit_code)
                    return
                end
                local binary = nil
                for item in vim.fs.dir(temp_dir) do
                    -- for _, item in ipairs(vim.fn.readdir(temp_dir)) do
                    if item:match('rust%-analyzer') then
                        binary = item
                        break
                    end
                end
                if not binary then
                    error_callback("Unable to locate rust-analyzer binary after download", -1)
                    return
                end
                local full_path = string.format("%s/%s", temp_dir, binary)
                vim.fs.chmod(full_path, "r-xr-xr-x")
                vim.fs.mv(full_path, editor_lsp)
                vim.fs.rm(temp_dir, { recursive = true, force = true })
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

-----------------------------------------------------------------------------------------------------
--============================================ INIT ===============================================--
-----------------------------------------------------------------------------------------------------

-- Check if the lua language server is in our path
local editor_config = vim.g._config
if not editor_config.languages then
    editor_config.languages = {}
end
if not editor_config.languages.rust then
    ---@type Rust
    editor_config.languages.rust = {
        configured = false,
        ---@type Lsp[]
        lsps = {
            ---@type Lsp
            rust_analyzer = {
                name = "rust-analyzer",
                enable = false,
                required = true,
                needs_update = M.rust_analyzer_needs_update,
                needs_install = function() return not M.is_rust_analyzer_installed() end,
                version = M.get_current_rust_analyzer_version,
                install = function(s, e, opts) M.install_rust_analyzer(s, e, opts) end,
                get_binary_path = M.rust_analyzer_get_binary_path,
                latest_version = M.get_latest_rust_analyzer_version,
                config = {
                    cmd = { "$LSP_BIN" }
                }
            }
        }
    }
end

rust = editor_config.languages.rust
if rust.configured then
    -- If we have already configured lua, there is nothing else for us to do
    return
end

local lsp = require('scripts.lsp')
for _, rust_lsp in pairs(rust.lsps) do
    lsp.register("rust", rust_lsp)
end

rust.configured = true
vim.g._config = editor_config
