if _G.__miversen_lsp_python_setup then
    return
end

local jit = require("jit")
local editor_dir = string.format("%s/miversen", vim.fn.stdpath("data"))
local editor_venv = string.format("%s/miversen/venv", vim.fn.stdpath('data'))

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
local function get_package_manager()
    local python_path = get_python_path(editor_venv)
    
    if vim.fn.executable('uv') == 1 then
        return {
            name = "uv",
            create_venv = function() return {"uv", "venv", editor_venv} end,
            install_packages = function(packages) 
                local cmd = {"uv", "pip", "install", "--python", python_path, "--native-tls"}
                vim.list_extend(cmd, packages)
                return cmd
            end
        }
    elseif vim.fn.executable('pip') == 1 then
        return {
            name = "pip", 
            create_venv = function() return {"python3", "-m", "venv", editor_venv} end,
            install_packages = function(packages)
                local cmd = {python_path, "-m", "pip", "install"}
                vim.list_extend(cmd, packages)
                return cmd
            end
        }
    end
    return nil
end

-- Execute command with proper error handling
local function execute_command(cmd, success_msg, error_msg, callback)
    vim.system(cmd, {}, function(result)
        if result.code == 0 then
            if success_msg then vim.notify(success_msg, vim.log.levels.DEBUG) end
            if callback then callback() end
        else
            vim.notify(string.format("%s. Exit code: %d, Error: %s", 
                error_msg, result.code, result.stderr or "Unknown error"), 
                vim.log.levels.ERROR)
        end
    end)
end

-- Check what default packages need to be installed (editor-level only)
local function get_missing_packages()
    local missing = {}
    for lsp_name, _ in pairs(default_lsps) do
        local lsp_path = get_bin_path(editor_venv, lsp_name)
        if vim.fn.filereadable(lsp_path) == 0 then
            table.insert(missing, lsp_name)
        end
    end
    return missing
end

-- Install missing LSPs to editor venv
local function install_editor_lsps(callback)
    local pm = get_package_manager()
    if not pm then
        if not vim.g.__miversen_warned_python_package_manager then
            vim.notify('Unable to locate a valid python package manager!', vim.log.levels.WARNING)
            vim.g.__miversen_warned_python_package_manager = true
        end
        return
    end

    vim.fn.mkdir(editor_dir, 'p')
    
    local missing_packages = get_missing_packages()
    if #missing_packages == 0 then
        if callback then callback() end
        return
    end

    local install_packages = function()
        vim.notify(string.format("Installing %s with %s", 
            table.concat(missing_packages, ', '), pm.name), vim.log.levels.INFO)
        execute_command(
            pm.install_packages(missing_packages),
            "Successfully installed LSP packages",
            "Failed to install LSP packages",
            callback
        )
    end

    -- Create venv if it doesn't exist, then install packages
    if vim.fn.isdirectory(editor_venv) == 0 then
        vim.notify(string.format("Creating editor venv with %s", pm.name), vim.log.levels.INFO)
        execute_command(
            pm.create_venv(),
            "Successfully created editor venv",
            "Failed to create editor venv",
            install_packages
        )
    else
        install_packages()
    end
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
        _G.__miversen_config.lsp.activate(lsp_name, config)
    end
end

-- Main logic
local function setup_python_lsps()
    local project_root = vim.fs.root(0, project_root_markers)
    local project_lsps = {}
    local found_genuine_lsp = false

    -- Try to find project-specific LSPs first
    if project_root then
        vim.notify(string.format("Python project root: %s", project_root), vim.log.levels.DEBUG)
        
        -- Find project venv
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

    -- Fall back to editor LSPs if no genuine project LSP found
    if not found_genuine_lsp then
        vim.notify("Setting up editor LSPs", vim.log.levels.DEBUG)
        install_editor_lsps(function()
            local editor_lsps = vim.tbl_keys(default_lsps) -- Only install default LSPs
            local editor_bin_dir = get_bin_path(editor_venv, ""):sub(1, -2) -- Remove trailing /
            vim.schedule(function() 
                activate_lsps(editor_lsps, editor_bin_dir, nil) 
            end)
        end)
    end
end

setup_python_lsps()
_G.__miversen_lsp_python_setup = true
