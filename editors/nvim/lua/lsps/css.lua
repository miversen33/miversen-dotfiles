-- lsps/css.lua

local shell = require("scripts.shell")

-- We know its grumpy, the fields are declared below. Shut up
---@diagnostic disable-next-line: missing-fields
---@type Lsp
local css_ls = {
    name = "cssls",
    _latest_version = nil,
    _current_version = nil,
    ---@type vim.lsp.Config
    config = {
        cmd = { "$LSP_BIN", "--stdio" },
        filetypes = { "css", "scss", "less" },
    },
}

---@return string The path that contains the language server
local function get_editor_lsp_dir()
    return string.format("%s/miversen/lsps/css", vim.fn.stdpath("data"))
end

---@param ignore boolean? If provided, we will still return the proper path even if we aren't installed
---@return string The path to the binary. May be "MISSING BINARY" if the binary is not able to be located
function css_ls.get_binary_path(ignore)
    local editor_lsp = string.format("%s/css-ls/node_modules/.bin/vscode-css-language-server", get_editor_lsp_dir())
    if ignore or vim.fn.filereadable(editor_lsp) == 1 then
        return editor_lsp
    else
        return "MISSING BINARY"
    end
end

function css_ls.needs_install()
    return vim.fn.filereadable(css_ls.get_binary_path()) ~= 1
end

-- Downloads and installs the css language server
---@param success_callback fun() The function to call upon successful installation of the language server
---@param error_callback fun(message: string, exit_code: number?) The function to call upon failure. Failure is any end state other than success
---@param install_opts LspInstallOpts? Any install options to use here
function css_ls.install(success_callback, error_callback, install_opts)
    install_opts = install_opts or { force = false }

    local target_path = string.format("%s/css-ls", get_editor_lsp_dir())
    local temp_dir = string.format("%s/neovim_miversen_lsp_download-css-%s",
        vim.uv.os_tmpdir(), os.date("%Y%m%d%H%M%S"))

    -- Skip installation if already exists and not forced
    if not install_opts.force and css_ls.get_binary_path() ~= "MISSING BINARY" then
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

    ---@param version string The version to install
    local function install_from_npm(version)
        vim.notify("Installing CSS Language Server from npm", vim.log.levels.DEBUG)

        local package_spec = string.format("vscode-langservers-extracted@%s", version)

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

            -- Check if the CSS language server was installed
            local server_path = string.format(
                "%s/node_modules/vscode-langservers-extracted/bin/vscode-css-language-server", temp_dir)
            if vim.fn.filereadable(server_path) == 0 then
                cleanup()
                error_callback("CSS language server binary not found after npm install", -1)
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

            vim.notify("CSS Language Server Installation Complete", vim.log.levels.INFO)
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
        css_ls.latest_version(function(version)
            if not version then
                cleanup()
                error_callback("Unable to determine latest CSS language server version", -1)
                return
            end
            install_from_npm(version)
        end)
    end
end

--Checks the current css language server version and returns it
--NOTE: Will return -1 if it cannot find the lsp
---@return string
function css_ls.version()
    if css_ls.needs_install() then
        css_ls._current_version = nil
        return "-1"
    end
    if css_ls._current_version then
        -- Lets used the cached version
        return css_ls._current_version
    end

    local package_json = string.format("%s/css-ls/node_modules/vscode-langservers-extracted/package.json",
        get_editor_lsp_dir())
    if vim.fn.filereadable(package_json) ~= 1 then
        css_ls._current_version = nil
        return "-1"
    end

    ---@type string[]
    local package_json_content = vim.fn.readfile(package_json)
    if not package_json_content then
        css_ls._current_version = nil
        return "-1"
    end

    ---@type table
    local package_data = vim.json.decode(table.concat(package_json_content, ""))
    if not package_data then
        css_ls._current_version = nil
        return "-1"
    end

    local version = package_data.version
    if not version then
        css_ls._current_version = nil
        return "-1"
    else
        css_ls._current_version = version
        return version
    end
end

---@param callback fun(version: string?) If provided, we will provide the latest version (or nothing if we can't find it)
function css_ls.latest_version(callback)
    if css_ls._latest_version then
        callback(css_ls._latest_version)
        return
    end

    local npm_api = "https://registry.npmjs.org/vscode-langservers-extracted/latest"

    ---@param result Shell.Serial
    local complete = function(result)
        if result.exit_code ~= 0 or result.stdout:len() == 0 then
            css_ls._latest_version = nil
            callback()
            return
        end

        local output = vim.json.decode(result.stdout)
        if not output then
            css_ls._latest_version = nil
            callback()
            return
        end

        local version = output.version
        if not version then
            css_ls._latest_version = nil
            callback()
            return
        end

        css_ls._latest_version = version
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
function css_ls.needs_update(callback)
    -- If we aren't installed, we can't update
    if css_ls.needs_install() then
        callback(false)
        return
    end
    local current_version = css_ls.version()
    ---@param latest_version string?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
        else
            callback(current_version < latest_version)
        end
    end
    css_ls.latest_version(complete)
    return
end

return {
    css_ls
}
