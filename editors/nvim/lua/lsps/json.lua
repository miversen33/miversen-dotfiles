-- lsps/json.lua

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
    x64 = "amd64"
}

-- We know its grumpy, the fields are declared below. Shut up
---@diagnostic disable-next-line: missing-fields
---@type Lsp
local jsonls       = {
    url =
    "https://github.com/microsoft/vscode-json-languageservice/archive/refs/tags/v${VERSION}.zip",
    name = "jsonls",
    _latest_version = nil,
    _current_version = nil,
    ---@type vim.lsp.Config
    config = {
        cmd = { "$LSP_BIN", "--stdio" },
        filetypes = { "json", "jsonc" },
    },
}

-- We know its grumpy, the fields are declared below. Shut up
---@diagnostic disable-next-line: missing-fields
---@type Lsp
local jq           = {
    url =
    "https://github.com/jqlang/jq/releases/download/jq-${VERSION}/jq-linux-${ARCH}",
    name = "jq",
    _latest_version = nil,
    _current_version = nil,
    enable = false,
    required = true,
    ---@type vim.lsp.Config
    config = {
        filetypes = { "json", "jsonc" }
    }
}

---------- Json Language Server

---@return string The path that contains the language server
local function get_editor_lsp_dir()
    return string.format("%s/miversen/lsps/json", vim.fn.stdpath("data"))
end

---@param ignore boolean? If provided, we will still return the proper path even if we aren't installed
---@return string The path to the binary. May be "MISSING BINARY" if the binary is not able to be located
function jsonls.get_binary_path(ignore)
    local editor_lsp = string.format("%s/jsonls/node_modules/.bin/vscode-json-language-server", get_editor_lsp_dir())
    if ignore or vim.fn.filereadable(editor_lsp) == 1 then
        return editor_lsp
    else
        return "MISSING BINARY"
    end
end

function jsonls.needs_install()
    return vim.fn.filereadable(jsonls.get_binary_path()) ~= 1
end

-- Downloads and install's the json language server
-- Note: If the installation is already available, there is no reason to redo all this (unless we are forced)
---@param success_callback fun() The function to call upon successful installation of the language server
---@param error_callback fun(message: string, exit_code: number?) The function to call upon failure. Failure is any end state other than success
---@param install_opts LspInstallOpts? Any install options to use here
function jsonls.install(success_callback, error_callback, install_opts)
    install_opts = install_opts or { force = false }

    local target_path = string.format("%s/jsonls", get_editor_lsp_dir())
    local temp_dir = string.format("%s/neovim_miversen_lsp_download-json-%s",
        vim.uv.os_tmpdir(), os.date("%Y%m%d%H%M%S"))

    -- Skip installation if already exists and not forced
    if not install_opts.force and jsonls.get_binary_path() ~= "MISSING BINARY" then
        success_callback()
        return
    end

    if vim.fn.isdirectory(target_path) ~= 1 then
        vim.fs.mkdir(target_path, 'p')
    end

    -- Clean up and create temp directory
    vim.fs.rm(temp_dir, { recursive = true, force = true })
    vim.fs.mkdir(temp_dir, 'p')

    local cleanup = function()
        vim.fs.rm(temp_dir, { force = true, recursive = true })
    end

    ---@param version string? The version to install, or nil for latest
    local function install_from_npm(version)
        vim.notify("Installing JSON Language Server from npm", vim.log.levels.DEBUG)

        local package_spec = "vscode-langservers-extracted"
        if version then
            package_spec = string.format("vscode-langservers-extracted@%s", version)
        end

        local cmd = {
            "docker", "run", "--rm",
            "-v", string.format("%s:/app", temp_dir),
            "-e", "CI=true",
            "-e", "npm_config_yes=true",
            "--user", string.format("%d:%d", vim.uv.getuid(), vim.uv.getgid()),
            "miversen-nvim-pnpm-compiler:0.0.1",
            "-c",
            string.format("npm install %s", package_spec)
        }

        ---@param result Shell.Serial
        local complete = function(result)
            if result.exit_code ~= 0 then
                cleanup()
                error_callback("Failed to install vscode-langservers-extracted: " .. (result.stderr or ""),
                    result.exit_code)
                return
            end

            -- Check if the JSON language server was installed
            local server_path = string.format(
                "%s/node_modules/vscode-langservers-extracted/bin/vscode-json-language-server", temp_dir)
            if vim.fn.filereadable(server_path) == 0 then
                cleanup()
                error_callback("JSON language server binary not found after npm install", -1)
                return
            end

            -- Copy the entire node_modules directory to get all dependencies
            local source = string.format("%s/node_modules", temp_dir)
            local target = string.format("%s/node_modules", target_path)

            -- Remove existing installation if it exists
            if vim.fn.isdirectory(target) == 1 then
                vim.fs.rm(target, { force = true, recursive = true })
            end

            vim.fs.mv(source, target)
            cleanup()

            vim.notify("JSON Language Server Installation Complete", vim.log.levels.INFO)
            success_callback()
        end

        local handle = shell:new(cmd, {
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete,
            [shell.CONSTANTS.FLAGS.STDERR_JOIN] = "",
        }):run()

        if not handle then
            cleanup()
            error_callback("Unable to start npm install", -1)
        end
    end

    -- Start the installation process - handle version properly
    if install_opts.version then
        install_from_npm(install_opts.version)
    else
        jsonls.latest_version(function(version)
            if not version then
                cleanup()
                error_callback("Unable to determine latest JSON language server version", -1)
                return
            end
            install_from_npm(version)
        end)
    end
end

--Checks the current jsonls version and returns it
--NOTE: Will return -1 if it cannot find the lsp
---@return string
function jsonls.version()
    if not jsonls.needs_install() then
        jsonls._current_version = nil
        return "-1"
    end
    if jsonls._current_version then
        -- Lets used the cached version
        return jsonls._current_version
    end
    local lsp_dir = string.format("%s/jsonls", get_editor_lsp_dir())
    if not lsp_dir or vim.fn.isdirectory(lsp_dir) ~= 1 then
        jsonls._current_version = nil
        return "-1"
    end
    local package_json = string.format("%s/package.json", lsp_dir)
    if vim.fn.filereadable(package_json) ~= 1 then
        jsonls._current_version = nil
        return "-1"
    end
    package_json = vim.fn.readfile(package_json)
    if not package_json then
        jsonls._current_version = nil
        return "-1"
    end
    ---@type string
    package_json = vim.json.decode(table.concat(package_json, ""))
    if not package_json then
        jsonls._current_version = nil
        return "-1"
    else
        jsonls._current_version = package_json.version
        return jsonls._current_version
    end
end

---@param callback fun(version: string?) If provided, we will provide the latest version (or nothing if we can't find it)
function jsonls.latest_version(callback)
    if jsonls._latest_version then
        callback(jsonls._latest_version)
        return
    end

    local npm_api = "https://registry.npmjs.org/vscode-langservers-extracted/latest"

    ---@param result Shell.Serial
    local complete = function(result)
        if result.exit_code ~= 0 or result.stdout:len() == 0 then
            jsonls._latest_version = nil
            callback()
            return
        end

        local output = vim.json.decode(result.stdout)
        if not output then
            jsonls._latest_version = nil
            callback()
            return
        end

        local version = output.version
        if not version then
            jsonls._latest_version = nil
            callback()
            return
        end

        jsonls._latest_version = version
        callback(version)
    end

    local handle = shell:new({ "curl", "-fsSL", npm_api }, {
        [shell.CONSTANTS.FLAGS.ASYNC] = true,
        [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete,
        [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = ""
    }):run()

    if not handle then
        callback()
    end
end

---@param callback fun(needs_update: boolean)
function jsonls.needs_update(callback)
    -- If we aren't installed, we can't update
    if not jsonls.needs_install() then
        callback(false)
        return
    end
    local current_version = jsonls.version()
    ---@param latest_version string?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
        else
            callback(current_version < latest_version)
        end
    end
    jsonls.latest_version(complete)
    return
end

---------- JQ

---@param ignore boolean? If provided, we will still return the proper path even if we aren't installed
---@return string The path to the binary. May be "MISSING BINARY" if the binary is not able to be located
function jq.get_binary_path(ignore)
    local editor_lsp = string.format("%s/jq", get_editor_lsp_dir())
    if ignore or vim.fn.filereadable(editor_lsp) == 1 then
        return editor_lsp
    else
        return "MISSING BINARY"
    end
end

function jq.needs_install()
    return vim.fn.filereadable(jq.get_binary_path()) ~= 1
end

-- Downloads and install's the json language server
-- Note: If the installation is already available, there is no reason to redo all this (unless we are forced)
---@param success_callback fun() The function to call upon successful installation of the language server
---@param error_callback fun(message: string, exit_code: number?) The function to call upon failure. Failure is any end state other than success
---@param install_opts LspInstallOpts? Any install options to use here
function jq.install(success_callback, error_callback, install_opts)
    install_opts = install_opts or { force = false }

    local target_path = string.format("%s/jq", get_editor_lsp_dir())

    -- Skip installation if already exists and not forced
    if not install_opts.force and jq.get_binary_path() ~= "MISSING BINARY" then
        success_callback()
        return
    end

    if vim.fn.isdirectory(target_path) ~= 1 then
        vim.fs.mkdir(target_path, 'p')
    end
    target_path = string.format("%s/jq", target_path)
    if vim.fn.filereadable(target_path) == 1 then
        -- Lets remove the installed version
        vim.fs.rm(target_path, { recursive = true, force = true })
    end

    ---@param result Shell.Serial
    local complete = function(result)
        if not result or result.exit_code ~= 0 then
            error_callback("Unable to download jq", result and result.exit_code or -1)
            return
        end
        vim.fs.chmod(target_path, "rwxr-xr-x")
        -- Lets update conform?
        -- Or should we have lsp do that?
        -- idk
        success_callback()
    end

    ---@param version string?
    local _install = function(version)
        if not version then
            error_callback("Unable to determine version to install for jq", -1)
            return
        end
        local url = jq.url:gsub("${VERSION}", version)
        url = url:gsub("${ARCH}", arch_map[jit.arch])
        url = url:gsub("${OS}", os_map[jit.os])
        local cmd = { "curl", "-fsSL", url, "-o", target_path }
        local handle = shell:new(cmd, {
            [shell.CONSTANTS.FLAGS.ASYNC] = true,
            [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = "",
            [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete
        }):run()
        if not handle then
            error_callback(string.format("Unable to download jq version %s", version), -1)
            return
        end
    end

    if install_opts.version then
        _install(install_opts.version)
    else
        jq.latest_version(_install)
    end
end

--Checks the current jq version and returns it
--NOTE: Will return -1 if it cannot find the lsp
---@return string
function jq.version()
    if not jq.needs_install() then
        jq._current_version = nil
        return "-1"
    end
    if jq._current_version then
        -- Lets used the cached version
        return jq._current_version
    end
    local lsp_dir = string.format("%s/jq", get_editor_lsp_dir())
    if not lsp_dir or vim.fn.isdirectory(lsp_dir) ~= 1 then
        jq._current_version = nil
        return "-1"
    end
    local version = shell:new({ jq.get_binary_path(), "--version" }, { [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = "" }):run()
    if not version or version.exit_code ~= 0 or not version.stdout then
        jq._current_version = nil
        return "-1"
    end
    version = version.stdout:gsub("^jq%-", "")
    if not version then
        jq._current_version = nil
        return "-1"
    else
        jq._current_version = version
        return version
    end
end

---@param callback fun(version: string?) If provided, we will provide the latest version (or nothing if we can't find it)
function jq.latest_version(callback)
    if jq._latest_version then
        callback(jq._latest_version)
        return
    end

    local jq_api = "https://api.github.com/repos/jqlang/jq/releases/latest"

    ---@param result Shell.Serial
    local complete = function(result)
        if result.exit_code ~= 0 or result.stdout:len() == 0 then
            jq._latest_version = nil
            callback()
            return
        end

        local output = vim.json.decode(result.stdout)
        if not output then
            jq._latest_version = nil
            callback()
            return
        end

        local version = output.tag_name
        if not version then
            jq._latest_version = nil
            callback()
            return
        end
        version = version:gsub("^jq%-", "")
        if not version then
            jq._latest_version = nil
            callback()
            return
        end
        jq._latest_version = version
        callback(version)
    end

    local handle = shell:new({ "curl", "-fsSL", jq_api }, {
        [shell.CONSTANTS.FLAGS.ASYNC] = true,
        [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete,
        [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = ""
    }):run()

    if not handle then
        callback()
    end
end

---@param callback fun(needs_update: boolean)
function jq.needs_update(callback)
    -- If we aren't installed, we can't update
    if not jq.needs_install() then
        callback(false)
        return
    end
    local current_version = jq.version()
    ---@param latest_version string?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
        else
            callback(current_version < latest_version)
        end
    end
    jq.latest_version(complete)
    return
end

return {
    jsonls,
    jq
}
