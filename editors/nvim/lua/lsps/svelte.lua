-- lsps/svelte.lua

local shell = require("scripts.shell")

-- We know its grumpy, the fields are declared below. Shut up
---@diagnostic disable-next-line: missing-fields
---@type Lsp
local svelte_ls = {
    name = "svelte",
    _latest_version = nil,
    _current_version = nil,
    ---@type vim.lsp.Config
    config = {
        cmd = { "$LSP_BIN", "--stdio" },
        filetypes = { "svelte" },
        root_dir = function(buffer, on_dir)
            local filename = vim.api.nvim_buf_get_name(buffer)
            if not filename or not filename:match('%.svelte$') then
                return
            end

            -- Look for Svelte project indicators starting from the file's directory
            local current_dir = vim.fn.fnamemodify(filename, ':h')
            local function find_svelte_root(dir)
                -- Check for package.json with svelte dependencies
                local package_json = dir .. '/package.json'
                if vim.fn.filereadable(package_json) == 1 then
                    local content = vim.fn.readfile(package_json)
                    if content then
                        local package_data = vim.json.decode(table.concat(content, ''))
                        if package_data then
                            -- Check for svelte in dependencies or devDependencies
                            local deps = package_data.dependencies or {}
                            local dev_deps = package_data.devDependencies or {}
                            if deps.svelte or dev_deps.svelte or
                                deps['@sveltejs/kit'] or dev_deps['@sveltejs/kit'] or
                                deps['@sveltejs/adapter-auto'] or dev_deps['@sveltejs/adapter-auto'] then
                                return dir
                            end
                        end
                    end
                end

                -- Check for svelte.config.js
                if vim.fn.filereadable(dir .. '/svelte.config.js') == 1 then
                    return dir
                end

                -- Check for vite.config.js with svelte plugin
                local vite_config = dir .. '/vite.config.js'
                if vim.fn.filereadable(vite_config) == 1 then
                    local content = vim.fn.readfile(vite_config)
                    if content then
                        local vite_content = table.concat(content, '\n')
                        if vite_content:match('@sveltejs/vite%-plugin%-svelte') or
                            vite_content:match('vite%-plugin%-svelte') then
                            return dir
                        end
                    end
                end

                -- Check parent directory
                local parent = vim.fn.fnamemodify(dir, ':h')
                if parent ~= dir and parent ~= '/' then
                    return find_svelte_root(parent)
                end

                return nil
            end

            local root = find_svelte_root(current_dir)
            if root then
                on_dir(root)
            end
        end
    },
}

---@return string The path that contains the language server
local function get_editor_lsp_dir()
    return string.format("%s/miversen/lsps/svelte", vim.fn.stdpath("data"))
end

---@param ignore boolean? If provided, we will still return the proper path even if we aren't installed
---@return string The path to the binary. May be "MISSING BINARY" if the binary is not able to be located
function svelte_ls.get_binary_path(ignore)
    local editor_lsp = string.format("%s/svelte-ls/node_modules/.bin/svelteserver",
        get_editor_lsp_dir())
    if ignore or vim.fn.filereadable(editor_lsp) == 1 then
        return editor_lsp
    else
        return "MISSING BINARY"
    end
end

function svelte_ls.needs_install()
    return vim.fn.filereadable(svelte_ls.get_binary_path()) ~= 1
end

-- Downloads and installs the svelte language server
---@param success_callback fun() The function to call upon successful installation of the language server
---@param error_callback fun(message: string, exit_code: number?) The function to call upon failure. Failure is any end state other than success
---@param install_opts LspInstallOpts? Any install options to use here
function svelte_ls.install(success_callback, error_callback, install_opts)
    install_opts = install_opts or { force = false }

    local target_path = string.format("%s/svelte-ls", get_editor_lsp_dir())
    local temp_dir = string.format("%s/neovim_miversen_lsp_download-svelte-%s",
        vim.uv.os_tmpdir(), os.date("%Y%m%d%H%M%S"))

    -- Skip installation if already exists and not forced
    if not install_opts.force and svelte_ls.get_binary_path() ~= "MISSING BINARY" then
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
        vim.notify("Installing Svelte Language Server from npm", vim.log.levels.DEBUG)

        local package_spec = string.format("svelte-language-server@%s", version)

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
                error_callback("Failed to install svelte-language-server: " .. (result.stderr or ""),
                    result.exit_code)
                return
            end

            -- Check if the Svelte language server was installed
            local server_path = string.format(
                "%s/node_modules/.bin/svelteserver", temp_dir)
            if vim.fn.filereadable(server_path) == 0 then
                cleanup()
                error_callback("Svelte language server binary not found after npm install", -1)
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

            vim.notify("Svelte Language Server Installation Complete", vim.log.levels.INFO)
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
        svelte_ls.latest_version(function(version)
            if not version then
                cleanup()
                error_callback("Unable to determine latest Svelte language server version", -1)
                return
            end
            install_from_npm(version)
        end)
    end
end

--Checks the current svelte language server version and returns it
--NOTE: Will return -1 if it cannot find the lsp
---@return string
function svelte_ls.version()
    if svelte_ls.needs_install() then
        svelte_ls._current_version = nil
        return "-1"
    end
    if svelte_ls._current_version then
        -- Lets used the cached version
        return svelte_ls._current_version
    end

    local package_json = string.format("%s/svelte-ls/node_modules/svelte-language-server/package.json",
        get_editor_lsp_dir())
    if vim.fn.filereadable(package_json) ~= 1 then
        svelte_ls._current_version = nil
        return "-1"
    end

    ---@type string[]
    local package_json_content = vim.fn.readfile(package_json)
    if not package_json_content then
        svelte_ls._current_version = nil
        return "-1"
    end

    ---@type table
    local package_data = vim.json.decode(table.concat(package_json_content, ""))
    if not package_data then
        svelte_ls._current_version = nil
        return "-1"
    end

    local version = package_data.version
    if not version then
        svelte_ls._current_version = nil
        return "-1"
    else
        svelte_ls._current_version = version
        return version
    end
end

---@param callback fun(version: string?) If provided, we will provide the latest version (or nothing if we can't find it)
function svelte_ls.latest_version(callback)
    if svelte_ls._latest_version then
        callback(svelte_ls._latest_version)
        return
    end

    local npm_api = "https://registry.npmjs.org/svelte-language-server/latest"

    ---@param result Shell.Serial
    local complete = function(result)
        if result.exit_code ~= 0 or result.stdout:len() == 0 then
            svelte_ls._latest_version = nil
            callback()
            return
        end

        local output = vim.json.decode(result.stdout)
        if not output then
            svelte_ls._latest_version = nil
            callback()
            return
        end

        local version = output.version
        if not version then
            svelte_ls._latest_version = nil
            callback()
            return
        end

        svelte_ls._latest_version = version
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
function svelte_ls.needs_update(callback)
    -- If we aren't installed, we can't update
    if svelte_ls.needs_install() then
        callback(false)
        return
    end
    local current_version = svelte_ls.version()
    ---@param latest_version string?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
        else
            callback(current_version < latest_version)
        end
    end
    svelte_ls.latest_version(complete)
    return
end

return {
    svelte_ls
}
