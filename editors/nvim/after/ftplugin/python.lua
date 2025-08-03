---@class PythonLsp
---@field configured boolean Is python configured yet?
---@field lsps table<string, Lsp> Lsps associated python

---@class PythonPackageManager
---@field is_available fun(): boolean A function that is called to check if this package manager is available
---@field install_venv fun(success_callback: fun(), error_callback: fun(error: string, exit_code: number?)) A function that can be called to create a new virtual environment
---@field install fun(packages: string|string[], success_callback: fun(), error_callback: fun(error: string, exit_code: number?)) A function to call to install new packages
---@field update fun(packages: string[], success_callback: fun(), error_callback: fun(error: string, exit_code: number?)) A function to call to update packages

local shell = require("scripts.shell")

local project_root_markers = {
    "pyproject.toml", "requirements.txt", ".vscode", ".nvim", ".venv", ".git"
}

local KNOWN_TOOLS = {
    "basedpyright", "pyright", "ruff", "ty", "pyrefly", "isort", "pylint", "flake8", "black", "autopep8", "autoimport",
    "rope" }

local M = {}

---@type table<string, PythonPackageManager>
local PACKAGE_MANAGERS = {
    uv = {
        is_available = function()
            return vim.fn.executable("uv") == 1
        end,
        install = function(packages, success_callback, error_callback)
            ---@param result Shell.Serial
            local complete = function(result)
                if result.exit_code == 0 then
                    success_callback()
                else
                    error_callback(result.stderr, result.exit_code)
                end
            end

            local _install = function(venv)
                local python_path = string.format("%s/bin/python", venv)
                local cmd = { "uv", "pip", "install", "--python", python_path, "--native-tls" }
                if type(packages) == "string" then
                    packages = { packages }
                end
                for _, package in ipairs(packages) do
                    table.insert(cmd, package)
                end
                local handle = shell:new(cmd, {
                    [shell.CONSTANTS.FLAGS.ASYNC] = true,
                    [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = "",
                    [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete
                }):run()
                if not handle then
                    -- complain
                    error_callback("Unable to install requested packages in editor virtual environment", -1)
                end
            end
            if not M._get_editor_venv() then
                -- We need to create the venv
                M._create_editor_venv(_install)
            else
                _install(M._get_editor_venv())
            end
        end,
        install_venv = function(success_callback, error_callback)
            local cmd = { 'uv', 'venv', M._get_editor_venv(true) }
            ---@param result Shell.Serial
            local complete = function(result)
                if result.exit_code ~= 0 then
                    -- Complain
                    vim.notify(result.stderr, vim.log.levels.DEBUG)
                    error_callback("Unable to create virtual environment with uv", result.exit_code)
                    return
                end
                success_callback()
            end
            local handle = shell:new(cmd, {
                [shell.CONSTANTS.FLAGS.ASYNC] = true,
                [shell.CONSTANTS.FLAGS.STDERR_JOIN] = "",
                [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete
            }):run()
            if not handle then
                -- the command failed to generate for some reason
                error_callback("Unable to create virtual environment with uv")
                return
            end
        end,
        update = function(packages, success_callback, error_callback) end,
    },
    pip = {
        is_available = function()
            return vim.fn.executable("pip") == 1 and vim.fn.executable("virtualenv") == 1
        end,
        install = function(packages, success_callback, error_callback)
            ---@param result Shell.Serial
            local complete = function(result)
                if result.exit_code == 0 then
                    success_callback()
                else
                    error_callback(result.stderr, result.exit_code)
                end
            end

            local _install = function(venv)
                local python_path = string.format("%s/bin/python", venv)
                local cmd = { python_path, "-m", "pip", "install", }
                if type(packages) == "string" then
                    packages = { packages }
                end
                for _, package in ipairs(packages) do
                    table.insert(cmd, package)
                end
                local handle = shell:new(cmd, {
                    [shell.CONSTANTS.FLAGS.ASYNC] = true,
                    [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = "",
                    [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete
                }):run()
                if not handle then
                    -- complain
                    error_callback("Unable to install requested packages in editor virtual environment", -1)
                end
            end
            if not M._get_editor_venv() then
                -- We need to create the venv
                M._create_editor_venv(_install)
            else
                _install(M._get_editor_venv())
            end
        end,
        install_venv = function(success_callback, error_callback)
            local cmd = { "python3", "-m", "virtualenv", M._get_editor_venv(true) }
            ---@param result Shell.Serial
            local complete = function(result)
                if result.exit_code ~= 0 then
                    -- Complain
                    vim.notify(result.stderr, vim.log.levels.DEBUG)
                    error_callback(result.stderr, result.exit_code)
                    return
                end
                success_callback()
            end
            local handle = shell:new(cmd, {
                [shell.CONSTANTS.FLAGS.ASYNC] = true,
                [shell.CONSTANTS.FLAGS.STDERR_JOIN] = "",
                [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete
            }):run()
            if not handle then
                -- the command failed to generate for some reason
                error_callback("Unable to create virtual environment with virtualenv")
                return
            end
        end,
        update = function(packages, success_callback, error_callback) end,
    }
}

---@type PythonLsp
local python = {}

-- Gets all known lsps/tools from the provided venv
---@param venv string The absolute path to the venv to search
---@return string[]
function M._get_venv_lsps(venv)
    -- Lets see if there is a known venv in here
    local venv_root = vim.fs.safe_root(0, venv)
    if not venv_root then
        -- We found a venv, lets use that
        return {}
    end
    local tools = {}
    local bin_dir = string.format("%s/bin", venv)
    for _, tool in ipairs(KNOWN_TOOLS) do
        local tool_path = string.format("%s/%s", bin_dir, tool)
        if vim.fn.filereadable(tool_path) == 1 then
            table.insert(tools, tool)
        end
    end
    return tools
end

-- Creates the editor venv
---@param callback fun(venv: string?)
function M._create_editor_venv(callback)
    local venv_dir = M._get_editor_venv(true)
    if venv_dir and vim.fn.isdirectory(venv_dir) == 1 then
        -- Lets assume the venv already exists
        callback(venv_dir)
        return
    end
    ---@type PythonPackageManager?
    local package_manager
    for _, pm in pairs(PACKAGE_MANAGERS) do
        if pm.is_available() then
            package_manager = pm
            break
        end
    end
    if not package_manager then
        -- Complain
        vim.notify("Unable to locate a valid python package manager", vim.log.levels.DEBUG, {})
        callback()
        return
    end
    package_manager.install_venv(
        function()
            callback(venv_dir)
        end,
        function(error, _)
            vim.notify(error, vim.log.levels.DEBUG, {})
            return
        end)
end

-- Installs binary in editor venv (creating it if needed)
---@param binaries string|string[] The binary to install
---@param success_callback fun() The function to call on successful insatllation
---@param error_callback fun(error: string, exit_code: number?) The function to call on error
function M._install_binaries_in_editor_venv(binaries, success_callback, error_callback)
    ---@type PythonPackageManager
    local pm
    for _, package_manager in pairs(PACKAGE_MANAGERS) do
        if package_manager.is_available() then
            pm = package_manager
            break
        end
    end
    if not pm then
        error_callback("No valid python package manager found")
        return
    end
    pm.install(binaries, success_callback, error_callback)
end

-- Returns the editor venv or empty string if we can't find it
---@return string?
function M._get_editor_venv(force)
    local lsp_dir = string.format("%s/miversen/lsps", vim.fn.stdpath('data'))
    local venv_dir = string.format("%s/python/venv", lsp_dir)
    if not force and vim.fn.isdirectory(venv_dir) ~= 1 then
        -- The directory doesn't exist
        return
    end
    return venv_dir
end

-- Returns the current projects venv or nil
---@return string?
function M._get_project_venv()
    local _venv = vim.fn.environ()['VIRTUAL_ENV']
    if _venv and vim.fn.isdirectory(_venv) == 1 then
        return _venv
    end
    local known_venvs = {
        'venv', '.venv'
    }
    -- Is there a way for us to read the venv from pyproject.toml?
    local project_root = vim.fs.root(0, project_root_markers)
    if project_root then
        -- Lets see if there is a known venv in here
        local venv_root = vim.fs.root(0, known_venvs)
        if venv_root then
            -- We found a venv, lets use that
            return venv_root
        end
    end
    return
end

-- Gets the path to the binary. Will check the project venv first and then the editor one
---@param binary_name string The name of the binary to get the path of
---@param ignore boolean? If provided, we will ignore the fact that the binary may not exist
---@return string
local function _get_binary_path(binary_name, ignore)
    local project_venv = M._get_project_venv()
    local editor_venv = M._get_editor_venv(true)
    local project_lsp = string.format("%s/bin/%s", project_venv, binary_name)
    local editor_lsp = string.format("%s/bin/%s", editor_venv, binary_name)
    if project_venv and vim.fn.filereadable(project_lsp) == 1 then
        return project_lsp
    elseif ignore or (editor_venv and vim.fn.filereadable(editor_lsp) == 1) then
        return editor_lsp
    else
        return "MISSING BINARY"
    end
end

---@param ignore boolean? If provided, we will still return the proper path even if we aren't installed
---@return string The path to the binary. May be "MISSING BINARY" if the binary is not able to be located
function M.basedpyright_get_path(ignore)
    return _get_binary_path("basedpyright", ignore)
end

---@param ignore boolean? If provided, we will still return the proper path even if we aren't installed
---@return string The path to the binary. May be "MISSING BINARY" if the binary is not able to be located
function M.pyrefly_get_path(ignore)
    return _get_binary_path("pyrefly", ignore)
end

---@param ignore boolean? If provided, we will still return the proper path even if we aren't installed
---@return string The path to the binary. May be "MISSING BINARY" if the binary is not able to be located
function M.ruff_get_path(ignore)
    return _get_binary_path("ruff", ignore)
end

---@param ignore boolean? If provided, we will still return the proper path even if we aren't installed
---@return string The path to the binary. May be "MISSING BINARY" if the binary is not able to be located
function M.ty_get_path(ignore)
    return _get_binary_path("ty", ignore)
end

---@return boolean
function M.is_basedpyright_installed()
    return vim.fn.filereadable(M.basedpyright_get_path()) == 1
end

---@return boolean
function M.is_pyrefly_installed()
    return vim.fn.filereadable(M.pyrefly_get_path()) == 1
end

---@return boolean
function M.is_ruff_installed()
    return vim.fn.filereadable(M.ruff_get_path()) == 1
end

---@return boolean
function M.is_ty_installed()
    return vim.fn.filereadable(M.ty_get_path()) == 1
end

-- Checks the current basedpyright version and returns it
---@return string
function M.get_basedpyright_version()
    if not M.is_basedpyright_installed() then
        python.lsps.basedpyright._current_version = nil
        return "-1"
    end
    if python.lsps.basedpyright._current_version then
        return python.lsps.basedpyright._current_version
    end
    local editor_lsp = M.basedpyright_get_path()

    local basedpyright_current_version = shell:new({ editor_lsp, "--version" }):run().stdout
    if not basedpyright_current_version or #basedpyright_current_version < 1 then
        python.lsps.basedpyright._current_version = nil
        return "-1"
    end
    basedpyright_current_version = string.gsub(basedpyright_current_version[1], 'basedpyright ', '')
    return basedpyright_current_version
end

-- Checks the current pyrefly version and returns it
---@return string
function M.get_pyrefly_version()
    if not M.is_pyrefly_installed() then
        python.lsps.pyrefly._current_version = nil
        return "-1"
    end
    if python.lsps.pyrefly._current_version then
        return python.lsps.pyrefly._current_version
    end
    local editor_lsp = M.basedpyright_get_path()

    local current_version = shell:new({ editor_lsp, "--version" }):run().stdout
    if not current_version or #current_version < 1 then
        python.lsps.pyrefly._current_version = nil
        return "-1"
    end
    current_version = string.gsub(current_version[1], 'pyrefly ', '')
    return current_version
end

-- Checks the current ty version and returns it
---@return string
function M.get_ty_version()
    if not M.is_ty_installed() then
        python.lsps.ty._current_version = nil
        return "-1"
    end
    if python.lsps.ty._current_version then
        return python.lsps.ty._current_version
    end
    local editor_lsp = M.ty_get_path()

    local ty_current_version = shell:new({ editor_lsp, "--version" }):run().stdout
    if not ty_current_version or #ty_current_version < 1 then
        python.lsps.ty._current_version = nil
        return "-1"
    end
    ty_current_version = string.gsub(ty_current_version[1], 'ty ', '')
    return ty_current_version
end

-- Checks the current ruff version and returns it
---@return string
function M.get_ruff_version()
    if not M.is_ruff_installed() then
        python.lsps.ruff._current_version = nil
        return "-1"
    end
    if python.lsps.ruff._current_version then
        return python.lsps.ruff._current_version
    end
    local editor_lsp = M.ruff_get_path()

    local ruff_current_version = shell:new({ editor_lsp, "--version" }):run().stdout
    if not ruff_current_version or #ruff_current_version < 1 then
        python.lsps.ruff._current_version = nil
        return "-1"
    end
    ruff_current_version = string.gsub(ruff_current_version[1], 'ruff ', '')
    return ruff_current_version
end

-- Gets the most current version of basedpyright
---@param callback fun(version: string?)
function M.get_basedpyright_latest_version(callback)
    local basedpyright_api = "https://api.github.com/repos/DetachHead/basedpyright/releases/latest"
    ---@param result Shell.Serial
    local complete = function(result)
        if result.exit_code ~= 0 then
            python.lsps.basedpyright._latest_version = nil
            callback()
            return
        end
        local output = vim.json.decode(result.stdout)
        if not output or not next(output) then
            -- Complain
            python.lsps.basedpyright._latest_version = nil
            callback()
            return
        end
        local version = output.tag_name
        if not version then
            -- Complain
            python.lsps.basedpyright._latest_version = nil
            callback()
            return
        end
        version = version:gsub('^v', '')
        python.lsps.basedpyright._latest_version = version
        callback(version)
        return
    end
    local handle = shell:new({ "curl", "-fsSL", basedpyright_api }, {
        [shell.CONSTANTS.FLAGS.ASYNC] = true,
        [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = '',
        [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete
    }):run()
    if not handle then
        -- complain
        vim.notify("Unable to get latest version of basedpyright from github", vim.log.levels.DEBUG, {})
        callback()
        return
    end
end

-- Gets the most current version of pyrefly
---@param callback fun(version: string?)
function M.get_pyrefly_latest_version(callback)
    local pyrefly_api = "https://api.github.com/repos/facebook/pyrefly/releases/latest"
    ---@param result Shell.Serial
    local complete = function(result)
        if result.exit_code ~= 0 then
            python.lsps.pyrefly._latest_version = nil
            callback()
            return
        end
        local output = vim.json.decode(result.stdout)
        if not output or not next(output) then
            -- Complain
            python.lsps.pyrefly._latest_version = nil
            callback()
            return
        end
        local version = output.tag_name
        if not version then
            -- Complain
            python.lsps.pyrefly._latest_version = nil
            callback()
            return
        end
        python.lsps.pyrefly._latest_version = version
        callback(version)
        return
    end
    local handle = shell:new({ "curl", "-fsSL", pyrefly_api }, {
        [shell.CONSTANTS.FLAGS.ASYNC] = true,
        [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = '',
        [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete
    }):run()
    if not handle then
        -- complain
        vim.notify("Unable to get latest version of pyrefly from github", vim.log.levels.DEBUG, {})
        callback()
        return
    end
end

-- Gets the most current version of ruff
---@param callback fun(version: string?)
function M.get_ruff_latest_version(callback)
    local ruff_api = "https://api.github.com/repos/astral-sh/ruff/releases/latest"
    ---@param result Shell.Serial
    local complete = function(result)
        if result.exit_code ~= 0 then
            python.lsps.ruff._latest_version = nil
            callback()
            return
        end
        local output = vim.json.decode(result.stdout)
        if not output or not next(output) then
            -- Complain
            python.lsps.ruff._latest_version = nil
            callback()
            return
        end
        local version = output.tag_name
        if not version then
            -- Complain
            python.lsps.ruff._latest_version = nil
            callback()
            return
        end
        python.lsps.ruff._latest_version = version
        callback(version)
        return
    end
    local handle = shell:new({ "curl", "-fsSL", ruff_api }, {
        [shell.CONSTANTS.FLAGS.ASYNC] = true,
        [shell.CONSTANTS.FLAGS.STDOUT_JOIN] = '',
        [shell.CONSTANTS.FLAGS.EXIT_CALLBACK] = complete
    }):run()
    if not handle then
        -- complain
        vim.notify("Unable to get latest version of ruff from github", vim.log.levels.DEBUG, {})
        callback()
        return
    end
end

-- Installs basedpyright into the editor venv
---@param success_callback fun() The function to call after successful installation
---@param error_callback fun(error: string, exit_code: number?) The function to call on failure to install
---@param install_opts LspInstallOpts? Options to use on install
function M._install_basedpyright(success_callback, error_callback, install_opts)
    local current_version = M.get_basedpyright_version()
    install_opts = install_opts or {
        force = false
    }
    if current_version and install_opts.version == current_version then
        -- Nothing to do
        success_callback()
        return
    end
    ---@param version string?
    local install = function(version)
        if not version then
            error_callback("Unable to determine the latest available version of basedpyright")
            return
        end
        if version == current_version and not install_opts.force then
            -- We are already up to date
            success_callback()
            return
        end
        local binary = string.format("basedpyright==%s", version)
        M._install_binaries_in_editor_venv(binary, success_callback, error_callback)
    end
    if not install_opts.version then
        M.get_basedpyright_latest_version(install)
    else
        install(install_opts.version)
    end
end

-- Installs pyrefly into the editor venv
---@param success_callback fun() The function to call after successful installation
---@param error_callback fun(error: string, exit_code: number?) The function to call on failure to install
---@param install_opts LspInstallOpts? Options to use on install
function M._install_pyrefly(success_callback, error_callback, install_opts)
    local current_version = M.get_pyrefly_version()
    install_opts = install_opts or {
        force = false
    }
    if current_version and install_opts.version == current_version then
        -- Nothing to do
        success_callback()
        return
    end
    ---@param version string?
    local install = function(version)
        if not version then
            error_callback("Unable to determine the latest available version of basedpyright")
            return
        end
        if version == current_version and not install_opts.force then
            -- We are already up to date
            success_callback()
            return
        end
        local binary = string.format("pyrefly==%s", version)
        M._install_binaries_in_editor_venv(binary, success_callback, error_callback)
    end
    if not install_opts.version then
        M.get_pyrefly_latest_version(install)
    else
        install(install_opts.version)
    end
end

-- Installs ruff into the editor venv
---@param success_callback fun() The function to call after successful installation
---@param error_callback fun(error: string, exit_code: number?) The function to call on failure to install
---@param install_opts LspInstallOpts? Options to use on install
function M._install_ruff(success_callback, error_callback, install_opts)
    local current_version = M.get_ruff_version()
    install_opts = install_opts or {
        force = false
    }
    if current_version and install_opts.version == current_version then
        -- Nothing to do
        success_callback()
        return
    end
    ---@param version string?
    local install = function(version)
        if not version then
            error_callback("Unable to determine the latest available version of basedpyright")
            return
        end
        if version == current_version and not install_opts.force then
            -- We are already up to date
            success_callback()
            return
        end
        local binary = string.format("ruff==%s", version)
        M._install_binaries_in_editor_venv(binary, success_callback, error_callback)
    end
    if not install_opts.version then
        M.get_ruff_latest_version(install)
    else
        install(install_opts.version)
    end
end

-- Checks to see if basedpyright need an update
---@param callback fun(needs_update: boolean?)
function M.basedpyright_needs_update(callback)
    local current_version = M.get_basedpyright_version()
    ---@param latest_version string?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
            return
        end
        callback(latest_version > current_version)
        return
    end
    M.get_basedpyright_latest_version(complete)
end

-- Checks to see if pyrefly need an update
---@param callback fun(needs_update: boolean?)
function M.pyrefly_needs_update(callback)
    local current_version = M.get_pyrefly_version()
    ---@param latest_version string?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
            return
        end
        callback(latest_version > current_version)
        return
    end
    M.get_pyrefly_latest_version(complete)
end

-- Checks to see if ruff need an update
---@param callback fun(needs_update: boolean?)
function M.ruff_needs_update(callback)
    local current_version = M.get_ruff_version()
    ---@param latest_version string?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
            return
        end
        callback(latest_version > current_version)
        return
    end
    M.get_ruff_latest_version(complete)
end

-----------------------------------------------------------------------------------------------------
--============================================ INIT ===============================================--
-----------------------------------------------------------------------------------------------------

-- Check if the lua language server is in our path
local editor_config = vim.g._config
if not editor_config.languages then
    editor_config.languages = {}
end
if not editor_config.languages.python then
    ---@type LuaLsp
    editor_config.languages.python = {
        configured = false,
        ---@type Lsp[]
        lsps = {
            basedpyright = {
                name = "basedpyright",
                enable = false,
                version = M.get_basedpyright_version,
                latest_version = M.get_basedpyright_latest_version,
                ---@type vim.lsp.Config
                config = {
                    cmd = { "$LSP_BIN-langserver", "--stdio" },
                    settings = {
                        basedpyright = {
                            analysis = {
                                typeCheckingMode = "standard",
                                diagnosticSeverityOverrides = {
                                    reportAssignmentType = false,
                                    reportArgumentType = "information",
                                    reportUnusedFunction = "information",
                                    reportOptionalMemberAccess = "information",
                                    reportRedeclaration = "information",
                                    reportImplicitOverride = false,
                                    reportAny = false
                                }
                            },
                            venvPath = "$VENV_PATH"
                        }
                    },
                },
                get_binary_path = M.basedpyright_get_path,
                get_editor_venv = M._get_editor_venv,
                needs_install = function() return not M.is_basedpyright_installed() end,
                needs_update = M.basedpyright_needs_update,
                install = M._install_basedpyright,
            },
            pyrefly = {
                name = "pyrefly",
                version = M.get_pyrefly_version,
                latest_version = M.get_pyrefly_latest_version,
                ---@type vim.lsp.Config
                config = {
                    cmd = { "$LSP_BIN", "lsp" },
                    root_markers = project_root_markers,
                    filetypes = { "python" },
                    settings = {},
                },
                get_editor_venv = M._get_editor_venv,
                get_binary_path = M.pyrefly_get_path,
                needs_install = function() return not M.is_pyrefly_installed() end,
                needs_update = M.pyrefly_needs_update,
                install = M._install_pyrefly,
            },
            ruff = {
                name = "ruff",
                version = M.get_ruff_version,
                latest_version = M.get_ruff_latest_version,
                ---@type vim.lsp.Config
                config = {
                    cmd = { "$LSP_BIN", "server" },
                    root_markers = project_root_markers,
                    filetypes = { "python" },
                    settings = {},
                },
                get_editor_venv = M._get_editor_venv,
                get_binary_path = M.ruff_get_path,
                needs_install = function() return not M.is_ruff_installed() end,
                needs_update = M.ruff_needs_update,
                install = M._install_ruff,
            }
        }
    }
end

python = editor_config.languages.python
if python.configured then
    -- If we have already configured python, there is nothing else for us to do
    return
end

python.M = M

local lsp = require('scripts.lsp')
for _, python_lsp in pairs(python.lsps) do
    lsp.register("python", python_lsp)
end

python.configured = true
vim.g._config = editor_config
