-- lsps/toml.lua

local uv           = vim.loop or vim.uv
local jit          = require("jit")
local architecture = jit.arch
local shell        = require("scripts.shell")

local os_map       = {
    Linux = 'unknown-linux-musl.gz',
    OSX = 'apple-darwin.gz',
    Windows = 'pc-windows.zip'
}

local arch_map     = {
    x64 = "x86_64"
}

-- We know its grumpy, the fields are declared below. Shut up
---@diagnostic disable-next-line: missing-fields
---@type Lsp
local tombi        = {
    url =
    "https://github.com/tombi-toml/tombi/releases/download/v${VERSION}/tombi-cli-${VERSION}-${ARCH}-${OS}",
    name = "tombi",
    _latest_version = nil,
    _current_version = nil,
    ---@type vim.lsp.Config
    config = {
        cmd = { "$LSP_BIN", "lsp" },
        filetypes = { "toml" },
    },
}

---------- Tombi

---@param ignore boolean? If provided, we will still return the proper path even if we aren't installed
---@return string The path to the binary. May be "MISSING BINARY" if the binary is not able to be located
function tombi.get_binary_path(ignore)
    local editor_dir = string.format("%s/miversen", vim.fn.stdpath("data"))
    local editor_lsp = string.format("%s/lsps/toml/tombi/tombi", editor_dir)
    if ignore or vim.fn.filereadable(editor_lsp) == 1 then
        return editor_lsp
    else
        return "MISSING BINARY"
    end
end

function tombi.needs_install()
    return vim.fn.filereadable(tombi.get_binary_path()) ~= 1
end

-- Installs Tombi
---@param success_callback fun() The function to call when install completes successfully
---@param error_callback fun(error: string, exit_code: number) The function to call when install fails
---@param opts LspInstallOpts? Options to use when installing
function tombi.install(success_callback, error_callback, opts)
    opts = opts or {}
    local force = opts.force or false
    -- This is completely wrong, we should be using "latest_version" not "version"
    local editor_lsp = tombi.get_binary_path(true)
    local editor_lsp_dir = vim.fs.dirname(editor_lsp)
    local temp_dir = string.format("%s/neovim_miversen_lsp_download-tombi-%s", uv.os_tmpdir(),
        os.date("%Y%m%d%H%M%S"))

    if vim.fn.filereadable(editor_lsp) == 1 and not force then
        -- This lsp already exists, return
        success_callback()
        return
    end

    -- We should remove whatever was there before
    vim.fs.rm(temp_dir, { recursive = true, force = true })
    vim.fs.rm(editor_lsp, { recursive = true, force = true })
    -- Download the lsp
    vim.notify("Downloading tombi language server", vim.log.levels.DEBUG, {})
    vim.fs.mkdir(editor_lsp_dir, 'p')
    vim.fs.mkdir(temp_dir, 'p')

    local output_file = string.format("%s/tombi.%s", temp_dir, jit.os == "Windows" and "zip" or "gz")
    local url = string.gsub(tombi.url, '${OS}', os_map[jit.os])
    url = string.gsub(url, '${ARCH}', arch_map[jit.arch])

    local function cleanup()
        vim.fs.rm(temp_dir, { recursive = true, force = true })
    end

    ---@param result Shell.Serial?
    local function place_and_complete(result)
        if not result or result.exit_code ~= 0 then
            -- Complain
            error_callback("Unable to extract tombi", result and result.exit_code or -1)
            cleanup()
            return
        end
        ---@type string
        local extracted_item = nil
        for item in vim.fs.dir(temp_dir) do
            if item:match("tombi") then
                extracted_item = string.format("%s/%s", temp_dir, item)
                break
            end
        end
        if not extracted_item then
            error_callback("Unable to locate extracted tombi", -1)
            cleanup()
            return
        end
        vim.fs.chmod(extracted_item, "rwxr-xr-x")
        vim.fs.mv(extracted_item, editor_lsp)
        cleanup()
        vim.notify(string.format("Installed tombi to %s", editor_lsp), vim.log.levels.INFO)
        success_callback()
    end

    ---@param result Shell.Serial?
    local function extract_lsp(result)
        if not result or result.exit_code ~= 0 then
            -- Complain
            error_callback("Unable to download tombi", result and result.exit_code or -1)
            cleanup()
            return
        end
        local cmd = {}
        -- We need to unzip depending on windows or linux
        if jit.os == "Windows" then
            cmd = {}
        else
            cmd = { "gzip", "-d", output_file }
        end
        local handle = shell:new(cmd, {
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = "",
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = place_and_complete
        }):run()
        if not handle then
            cleanup()
            error_callback("Unable to extract tombi", -1)
            return
        end
    end

    ---@param version string?
    local function download_lsp(version)
        if not version then
            -- complain
            error_callback("Unable to locate valid version of tombi", -1)
            cleanup()
            return
        end
        url = url:gsub("${VERSION}", version)

        vim.notify(string.format("Downloading tombi from %s", url), vim.log.levels.DEBUG, {})
        local handle = shell:new({ "curl", "-fsS", "-L", url, "-o", output_file }, {
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = "",
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = extract_lsp
        }):run()
        if not handle then
            cleanup()
            error_callback("Unable to download tombi", -1)
            return
        end
    end

    if opts.version then
        download_lsp(opts.version)
    else
        tombi.latest_version(download_lsp)
    end
end

--Checks the current tombi version and returns it
--NOTE: Will return -1 if it cannot find the lsp
---@return string
function tombi.version()
    if not tombi.needs_install() then
        tombi._current_version = nil
        return "-1"
    end
    if tombi._current_version then
        -- Lets used the cached version
        return tombi._current_version
    end
    local editor_lsp = tombi.get_binary_path()

    local tombi_ls_current_version = shell:new({ editor_lsp, "--version" }):run().stdout
    if not tombi_ls_current_version or #tombi_ls_current_version < 1 then
        tombi._current_version = nil
        return "-1"
    end
    tombi_ls_current_version = tombi_ls_current_version[1]:gsub("tombi ", "")
    if not tombi_ls_current_version then
        tombi._current_version = nil
        return "-1"
    else
        -- Lets cache the version so we can quickly pull it again without needing to shell out
        tombi._current_version = tombi_ls_current_version
        return tombi_ls_current_version
    end
end

---@param callback fun(version: string?)
function tombi.latest_version(callback)
    if tombi._latest_version then
        -- Lets use the cached version
        callback(tombi._latest_version)
        return
    end
    local tombi_ls_api = "https://api.github.com/repos/tombi-toml/tombi/releases/latest"
    ---@param result Shell.Serial
    local complete = function(result)
        local tombi_ls_latest_version
        if result.exit_code ~= 0 then
            tombi._latest_version = nil
            callback()
            -- Complain?
            return
        end
        local output = vim.json.decode(result.stdout)
        local version = output.tag_name
        if not version then
            tombi._latest_version = nil
            callback()
            return
        end
        version = version:gsub("^v", "")
        tombi._latest_version = version
        callback(version)
    end
    local handle = shell:new({ "curl", "-fsSL", tombi_ls_api },
        {
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

---@param callback fun(needs_update: boolean)
function tombi.needs_update(callback)
    -- If we aren't installed, we can't update
    if not tombi.needs_install() then
        callback(false)
        return
    end
    local current_version = tombi.version()
    ---@param latest_version string?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
        else
            callback(current_version < latest_version)
        end
    end
    tombi.latest_version(complete)
    return
end

return {
    tombi,
}
