---@class ConfigLspPackageManager
---@field name string The name of the package manager
---@field create_venv fun(venv: string): boolean A function that is called to create a new virtual environment
---@field install_packages fun(venv: string, packages: string[]): boolean A function that is called to install new packages within a new virtual environment

local editor_config = vim.g._config
if not editor_config.languages then
    editor_config.languages = {}
end
if not editor_config.languages.python then
    editor_config.languages.python = {}
end

local python = editor_config.languages.python
if python.configured then
    -- If we have already configured python, there is nothing else for us to do
    return
end

local jit = require("jit")
local editor_dir = string.format("%s/miversen", vim.fn.stdpath("data"))
local editor_venv = string.format("%s/miversen/venv", vim.fn.stdpath('data'))
local shell = vim.g._config.shell

local project_root_markers = {
    "pyproject.toml", "requirements.txt", ".vscode", ".nvim", ".venv", ".git"
}

local known_venvs = { '.venv', 'venv' }

-- LSPs that should be installed at the editor level (fallback)
local default_lsps = {
    basedpyright = {
        cmd = {"%BIN_PATH-langserver", "--stdio"},
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
                venvPath = "%VENV_PATH"
            }
        },
        _is_lsp = true
    },
    ruff = {
        cmd = {"%BIN_PATH", "server"},
        root_markers = project_root_markers,
        filetypes = { "python" },
        settings = {}
    },
}

-- All available LSP configurations (includes project-only LSPs)
local lsp_configs = vim.tbl_extend("force", default_lsps, {
    pyrefly = {
        cmd = {"%BIN_PATH", "lsp"},
        root_markers = project_root_markers,
        filetypes = { "python" },
        settings = {},
        _is_lsp = true,
    }
})

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


-- Helper function to get cross-platform paths
local function get_bin_path(venv_path, executable)
    local bin_dir = jit.os == "Windows" and "Scripts" or "bin"
    local ext = jit.os == "Windows" and ".exe" or ""
    return string.format("%s/%s/%s%s", venv_path, bin_dir, executable, ext)
end

local function get_python_path(venv_path)
    return get_bin_path(venv_path, "python")
end

-- Simplified package manager interface
---@return ConfigLspPackageManager?
local function get_package_manager()
    if vim.fn.executable('uv') == 1 then
        return {
            name = "uv",
            create_venv = function(venv) return {"uv", "venv", venv} end,
            install_packages = function(venv, packages) 
                local python_path = get_python_path(venv)
                local cmd = {"uv", "pip", "install", "--python", python_path, "--native-tls"}
                vim.list_extend(cmd, packages)
                return cmd
            end
        }
    elseif vim.fn.executable('pip') == 1 then
        return {
            name = "pip",
            create_venv = function(venv) return {"python3", "-m", "venv", venv} end,
            install_packages = function(venv, packages)
                local python_path = get_python_path(venv)
                local cmd = {python_path, "-m", "pip", "install"}
                vim.list_extend(cmd, packages)
                return cmd
            end
        }
    end
    return nil
end

-- Check what default packages need to be installed (editor-level only)
local function get_missing_packages(venv)
    local missing = {}
    for lsp_name, _ in pairs(default_lsps) do
        local lsp_path = get_bin_path(venv, lsp_name)
        if vim.fn.filereadable(lsp_path) == 0 then
            table.insert(missing, lsp_name)
        end
    end
    return missing
end

-- Replace template variables in LSP config
local function apply_config_variables(config, variables)
    local function replace_recursive(obj)
        if type(obj) == "table" then
            for k, v in pairs(obj) do
                obj[k] = replace_recursive(v)
            end
        elseif type(obj) == "string" then
            for pattern, replacement in pairs(variables) do
                obj = string.gsub(obj, pattern, replacement)
            end
        end
        return obj
    end
    return replace_recursive(vim.deepcopy(config))
end

-- Activate LSPs
local function activate_lsps(lsp_names, bin_dir, venv_path)
    for _, lsp_name in ipairs(lsp_names) do
        local config = apply_config_variables(lsp_configs[lsp_name], {
            ["%%BIN_PATH"] = string.format("%s/%s", bin_dir, lsp_name),
            ["%%VENV_PATH"] = venv_path or ""
        })
        editor_config.lsp.activate(lsp_name, config)
    end
end

-- Install missing LSPs to editor venv
local function install_editor_lsps(venv, callback)
    local pm = get_package_manager()
    if not pm then
        if not editor_config.languages.python.warned_package_manager then
            vim.notify('Unable to locate a valid python package manager!', vim.log.levels.WARNING)
            editor_config.languages.python.warned_package_manager = true
        end
        return
    end

    vim.fn.mkdir(editor_dir, 'p')
   
    -- We don't need a directory check first?
    local missing_packages = get_missing_packages(venv)
    if #missing_packages == 0 then
        if callback then callback() end
        return
    end

    local install_packages = function()
        vim.notify(string.format("Installing %s with %s", 
            table.concat(missing_packages, ', '), pm.name), vim.log.levels.DEBU)
        execute_command(
            pm.install_packages(venv, missing_packages),
            function()
                vim.notify("Successfully installed python LSP packages", vim.log.levels.DEBUG, {})
                callback()
            end,
            function(error)
                vim.notify("Failed to install python LSP packages", vim.log.levels.WARNING, {})
                vim.notify(error, vim.log.levels.DEBUG)
            end
        )
    end

    -- Create venv if it doesn't exist, then install packages
    if vim.fn.isdirectory(venv) == 0 then
        vim.notify(string.format("Creating editor venv with %s", pm.name), vim.log.levels.INFO)
        execute_command(
            pm.create_venv(editor_venv),
            function()
                vim.notify("Successfully created editor venv", vim.log.levels.DEBUG, {})
                install_packages()
            end,
            function(error)
                vim.notify("Failed to created editor venv", vim.log.levels.WARNING, {})
                vim.notify(error, vim.log.levels.DEBUG)
            end
        )
    else
        install_packages()
    end
end

local function main()
    local project_root = vim.fs.root(0, project_root_markers)
    local project_lsps = {}
    local found_genuine_lsp = false

    if project_root then
        -- We found a venv in the project, lets setup any lsp tooling there first
        vim.notify(string.format("Setting up python project %s", project_root), vim.log.levels.DEBUG)

        local venv_root = vim.fs.root(0, known_venvs)
        if venv_root then
            for _, venv_name in ipairs(known_venvs) do
                local venv_path = vim.fn.finddir(venv_name, venv_root .. "/**")
                if venv_path and venv_path ~= "" then
                    vim.notify(string.format("Found project venv: %s", venv_path), vim.log.levels.DEBUG)

                    local bin_dir = string.format("%s/%s/bin", project_root, venv_path)
                    for lsp_name, lsp_config in pairs(lsp_configs) do
                        local lsp_path = string.format("%s/%s", bin_dir, lsp_name)
                        if vim.fn.filereadable(lsp_path) == 1 then
                            table.insert(project_lsps, lsp_name)
                            if lsp_config._is_lsp then
                                found_genuine_lsp = true
                            end
                        end
                    end

                    if #project_lsps > 0 then
                        local full_venv_path = string.format("%s/%s", project_root, venv_path)
                        vim.schedule(function() 
                            activate_lsps(project_lsps, bin_dir, full_venv_path)
                        end)
                    end
                    break
                end
            end
        end

    end

    if not found_genuine_lsp then
        vim.notify("Setting up editor LSPs", vim.log.levels.DEBUG)
        install_editor_lsps(editor_venv, vim.schedule_wrap(function()
            local editor_lsps = vim.tbl_keys(default_lsps)
            local editor_bin_dir = get_bin_path(editor_venv, ""):sub(1, -2)
            activate_lsps(editor_lsps, editor_bin_dir, editor_venv)
        end))
    end
end

main()

python.configured = true
vim.g._config = editor_config
