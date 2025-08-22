-- lsps/python.lua

---@class PythonPackageManager
---@field name string The name of the package manager
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

local KNOWN_LSPS = {
    "pyright", "basedpyright", "pyrefly"
}

local KNOWN_FORMATTERS = {
    "ruff"
}

local M = {}

---@type table<string, PythonPackageManager>
local PACKAGE_MANAGERS = {
    uv = {
        name = "uv",
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
        name = "pip",
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

local pyrefly = {
    name = "pyrefly",
    ---@type vim.lsp.Config
    config = {
        cmd = { "$LSP_BIN", "lsp" },
        root_markers = project_root_markers,
        filetypes = { "python" },
        settings = {},
    },
    _latest_version = nil,
    _current_version = nil,
}

---@type Lsp
local ruff = {
    name = "ruff",
    ---@type vim.lsp.Config
    config = {
        cmd = { "$LSP_BIN", "server" },
        root_markers = project_root_markers,
        filetypes = { "python" },
        settings = {},
    },
    _latest_version = nil,
    _current_version = nil,
    formatter_opts = {
        command = "$LSP_BIN format"
    }
}

local basedpyright = {
    name = "basedpyright",
    enable = false,
    ---@type vim.lsp.Config
    config = {
        cmd = { "$LSP_BIN-langserver", "--stdio" },
        filetypes = { "python" },
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
    _latest_version = nil,
    _current_version = nil,
}


local ty = {
    name = "ty",
    enable = false,
    ---@type vim.lsp.Config
    config = {},
    _latest_version = nil,
    _current_version = nil,
}

---@return string?
function M.get_venv()
    local project_venv = M._get_project_venv()
    if project_venv then
        return project_venv
    else
        return M._get_editor_venv()
    end
end

-- Gets all known lsps/tools from the provided venv
---@param venv string The absolute path to the venv to search
---@return string[]
function M._get_venv_lsps(venv)
    if not venv then
        -- We didn't get a venv
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
function install_binaries_in_editor_venv(binaries, success_callback, error_callback)
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
    local buffer_name = vim.api.nvim_buf_get_name(0)
    -- Is there a way for us to read the venv from pyproject.toml?
    local project_root = vim.fs.safe_root(buffer_name, project_root_markers)
    if project_root then
        -- Lets see if there is a known venv in here
        for _, known_venv in ipairs(known_venvs) do
            venv = string.format("%s/%s", project_root, known_venv)
            if vim.fn.isdirectory(venv) == 1 then
                return venv
            end
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
function basedpyright.get_binary_path(ignore)
    return _get_binary_path("basedpyright", ignore)
end

---@param ignore boolean? If provided, we will still return the proper path even if we aren't installed
---@return string The path to the binary. May be "MISSING BINARY" if the binary is not able to be located
function pyrefly.get_binary_path(ignore)
    return _get_binary_path("pyrefly", ignore)
end

---@param ignore boolean? If provided, we will still return the proper path even if we aren't installed
---@return string The path to the binary. May be "MISSING BINARY" if the binary is not able to be located
function ruff.get_binary_path(ignore)
    return _get_binary_path("ruff", ignore)
end

---@param ignore boolean? If provided, we will still return the proper path even if we aren't installed
---@return string The path to the binary. May be "MISSING BINARY" if the binary is not able to be located
function ty.get_binary_path(ignore)
    return _get_binary_path("ty", ignore)
end

---@return boolean
function basedpyright.needs_install()
    return vim.fn.filereadable(basedpyright.get_binary_path()) ~= 1
end

---@return boolean
function pyrefly.needs_install()
    return vim.fn.filereadable(pyrefly.get_binary_path()) ~= 1
end

---@return boolean
function ruff.needs_install()
    return vim.fn.filereadable(ruff.get_binary_path()) ~= 1
end

---@return boolean
function ty.needs_install()
    return vim.fn.filereadable(ty.get_binary_path()) ~= 1
end

-- Checks the current basedpyright version and returns it
---@return string
function basedpyright.version()
    if not basedpyright.needs_install() then
        basedpyright._current_version = nil
        return "-1"
    end
    if basedpyright._current_version then
        return basedpyright._current_version
    end
    local editor_lsp = basedpyright.get_binary_path()

    local basedpyright_current_version = shell:new({ editor_lsp, "--version" }):run().stdout
    if not basedpyright_current_version or #basedpyright_current_version < 1 then
        basedpyright._current_version = nil
        return "-1"
    end
    basedpyright_current_version = string.gsub(basedpyright_current_version[1], 'basedpyright ', '')
    return basedpyright_current_version
end

-- Checks the current pyrefly version and returns it
---@return string
function pyrefly.version()
    if not pyrefly.needs_install() then
        pyrefly._current_version = nil
        return "-1"
    end
    if pyrefly._current_version then
        return pyrefly._current_version
    end
    local editor_lsp = pyrefly.get_binary_path()

    local current_version = shell:new({ editor_lsp, "--version" }):run().stdout
    if not current_version or #current_version < 1 then
        pyrefly._current_version = nil
        return "-1"
    end
    current_version = string.gsub(current_version[1], 'pyrefly ', '')
    return current_version
end

-- Checks the current ty version and returns it
---@return string
function ty.version()
    if not ty.needs_install() then
        ty._current_version = nil
        return "-1"
    end
    if ty._current_version then
        return ty._current_version
    end
    local editor_lsp = ty.get_binary_path()

    local ty_current_version = shell:new({ editor_lsp, "--version" }):run().stdout
    if not ty_current_version or #ty_current_version < 1 then
        ty._current_version = nil
        return "-1"
    end
    ty_current_version = string.gsub(ty_current_version[1], 'ty ', '')
    return ty_current_version
end

-- Checks the current ruff version and returns it
---@return string
function ruff.version()
    if not ruff.needs_install() then
        ruff._current_version = nil
        return "-1"
    end
    if ruff._current_version then
        return ruff._current_version
    end
    local editor_lsp = ruff.get_binary_path()

    local ruff_current_version = shell:new({ editor_lsp, "--version" }):run().stdout
    if not ruff_current_version or #ruff_current_version < 1 then
        ruff._current_version = nil
        return "-1"
    end
    ruff_current_version = string.gsub(ruff_current_version[1], 'ruff ', '')
    return ruff_current_version
end

-- Gets the most current version of basedpyright
---@param callback fun(version: string?)
function basedpyright.latest_version(callback)
    local basedpyright_api = "https://api.github.com/repos/DetachHead/basedpyright/releases/latest"
    ---@param result Shell.Serial
    local complete = function(result)
        if result.exit_code ~= 0 then
            basedpyright._latest_version = nil
            callback()
            return
        end
        local output = vim.json.decode(result.stdout)
        if not output or not next(output) then
            -- Complain
            basedpyright._latest_version = nil
            callback()
            return
        end
        local version = output.tag_name
        if not version then
            -- Complain
            basedpyright._latest_version = nil
            callback()
            return
        end
        version = version:gsub('^v', '')
        basedpyright._latest_version = version
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
function pyrefly.latest_version(callback)
    local pyrefly_api = "https://api.github.com/repos/facebook/pyrefly/releases/latest"
    ---@param result Shell.Serial
    local complete = function(result)
        if result.exit_code ~= 0 then
            pyrefly._latest_version = nil
            callback()
            return
        end
        local output = vim.json.decode(result.stdout)
        if not output or not next(output) then
            -- Complain
            pyrefly._latest_version = nil
            callback()
            return
        end
        local version = output.tag_name
        if not version then
            -- Complain
            pyrefly._latest_version = nil
            callback()
            return
        end
        pyrefly._latest_version = version
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
function ruff.latest_version(callback)
    local ruff_api = "https://api.github.com/repos/astral-sh/ruff/releases/latest"
    ---@param result Shell.Serial
    local complete = function(result)
        if result.exit_code ~= 0 then
            ruff._latest_version = nil
            callback()
            return
        end
        local output = vim.json.decode(result.stdout)
        if not output or not next(output) then
            -- Complain
            ruff._latest_version = nil
            callback()
            return
        end
        local version = output.tag_name
        if not version then
            -- Complain
            ruff._latest_version = nil
            callback()
            return
        end
        ruff._latest_version = version
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
function basedpyright.install(success_callback, error_callback, install_opts)
    local current_version = basedpyright.version()
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
        install_binaries_in_editor_venv(binary, success_callback, error_callback)
    end
    if not install_opts.version then
        basedpyright.latest_version(install)
    else
        install(install_opts.version)
    end
end

-- Installs pyrefly into the editor venv
---@param success_callback fun() The function to call after successful installation
---@param error_callback fun(error: string, exit_code: number?) The function to call on failure to install
---@param install_opts LspInstallOpts? Options to use on install
function pyrefly.install(success_callback, error_callback, install_opts)
    local current_version = pyrefly.version()
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
        install_binaries_in_editor_venv(binary, success_callback, error_callback)
    end
    if not install_opts.version then
        pyrefly.latest_version(install)
    else
        install(install_opts.version)
    end
end

-- Installs ruff into the editor venv
---@param success_callback fun() The function to call after successful installation
---@param error_callback fun(error: string, exit_code: number?) The function to call on failure to install
---@param install_opts LspInstallOpts? Options to use on install
function ruff.install(success_callback, error_callback, install_opts)
    local current_version = ruff.version()
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
        install_binaries_in_editor_venv(binary, success_callback, error_callback)
    end
    if not install_opts.version then
        ruff.latest_version(install)
    else
        install(install_opts.version)
    end
end

-- Checks to see if basedpyright need an update
---@param callback fun(needs_update: boolean?)
function basedpyright.needs_update(callback)
    local current_version = basedpyright.version()
    ---@param latest_version string?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
            return
        end
        callback(latest_version > current_version)
        return
    end
    basedpyright.latest_version(complete)
end

-- Checks to see if pyrefly need an update
---@param callback fun(needs_update: boolean?)
function pyrefly.needs_update(callback)
    local current_version = pyrefly.version()
    ---@param latest_version string?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
            return
        end
        callback(latest_version > current_version)
        return
    end
    pyrefly.latest_version(complete)
end

-- Checks to see if ruff need an update
---@param callback fun(needs_update: boolean?)
function ruff.needs_update(callback)
    local current_version = ruff.version()
    ---@param latest_version string?
    local complete = function(latest_version)
        if not latest_version then
            callback(false)
            return
        end
        callback(latest_version > current_version)
        return
    end
    ruff.latest_version(complete)
end

local map = {
    pyrefly = pyrefly,
    ruff = ruff,
    basedpyright = basedpyright
}

local venv_lsps = M._get_venv_lsps(M._get_project_venv())
local _lsps = {}
local found_lsp = false
for _, lsp_name in ipairs(venv_lsps) do
    for _, known_lsp in ipairs(KNOWN_LSPS) do
        if lsp_name == known_lsp then
            found_lsp = true
            break
        end
    end
    local _lsp = map[lsp_name]
    if _lsp then
        _lsp.enable = true
        table.insert(_lsps, _lsp)
    end
end

if not found_lsp then
    -- We need to provide our own LSPs
    table.insert(_lsps, pyrefly)
end

local found_formatter = false
for _, tool_name in ipairs(KNOWN_FORMATTERS) do
    for _, _lsp in ipairs(_lsps) do
        if tool_name == _lsp.name then
            found_formatter = true
            break
        end
    end
    local _tool = map[tool_name]
    if _tool then
        _tool.enable = true
        table.insert(_lsps, _tool)
    end
end

if not found_formatter then
    -- We need to provide our own formatters
    table.insert(_lsps, ruff)
end

for _, lsp in ipairs(_lsps) do
    lsp.get_venv = M.get_venv
end

return _lsps
