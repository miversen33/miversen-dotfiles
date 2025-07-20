if _G.__miversen_lsp_python_setup then
    -- Nothing to do here
    return
end
local uv = vim.uv or vim.loop
local jit = require("jit")
local editor_dir = string.format("%s/miversen", vim.fn.stdpath("data"))
local editor_venv = string.format("%s/miversen/venv", vim.fn.stdpath('data'))

local project_root_markers = {
    "pyproject.toml",
    "requirements.txt",
    ".vscode",
    ".nvim",
    ".venv",
    ".git"
}

local known_venvs = {
    '.venv',
    'venv'
}

local defaults = {
    basedpyright = {
        cmd = {"%BIN_PATH-langserver", "--stdio"},
        settings = {
            settings = {
                basedpyright = {
                    -- https://docs.basedpyright.com/#/configuration
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
            }
        },
    },
    ruff = {
        cmd = {"%BIN_PATH", "server"},
        root_markers = project_root_markers,
        filetypes = { "python" },
        settings = {}
    },
}

local lsps = {
    pyrefly = {
        cmd = {"%BIN_PATH", "lsp"},
        root_markers = project_root_markers,
        filetypes = { "python" },
        settings = {},
        _is_lsp = true,
    },
    ruff = defaults.ruff,
    basedpyright = defaults.basedpyright,
}

local function install_local_lsp(_success_callback)
    local python_path = jit.os == "Windows" 
        and string.format("%s/Scripts/python.exe", editor_venv)
        or string.format("%s/bin/python", editor_venv)

    local package_manager_map = {
        pip = {
            venv = function(success_callback, error_callback)
                success_callback = success_callback or function() end -- stub out success and error
                error_callback = error_callback or function(result)
                    vim.notify(string.format("Error occured while initializing editor venv \"%s\". Error Code: %i, Error: %s", editor_venv, result.code, result.stderr))
                    return
                end

                local command = {"python3", "-m", "venv", editor_venv}
                vim.system(command, {}, function(result)
                    if result.code > 0 then
                        error_callback(result)
                    else
                        success_callback()
                    end
 
                end)
            end,
            install = function(success_callback, error_callback, packages)
                success_callback = success_callback() or function() end -- stub out success and error
                error_callback = error_callback or function(result)
                    vim.notify(string.format("Error occured while installing %s. Error Code: %i, Error: %s", table.concat(packages, ' '), result.code, result.stderr))
                    return
                end

                local command = {string.format("%s/bin/python", editor_venv), "-m", "pip", "install", packages}
                vim.system(command, {}, function(result)
                    if result.code > 0 then
                        error_callback(result)
                    else
                        success_callback()
                    end

                end)
            end
        },
        uv = {
            venv = function(success_callback, error_callback)
                success_callback = success_callback or function() end -- stub out success and error
                error_callback = error_callback or function(result)
                    vim.notify(string.format("Error occured while initializing editor venv \"%s\". Error Code: %i, Error: %s", editor_venv, result.code, result.stderr))
                    return
                end

                local command = {"uv", "venv", editor_venv}
                vim.system(command, {}, function(result)
                    if result.code > 0 then
                        error_callback(result)
                    else
                        success_callback()
                    end
                end)
            end,
            install = function(success_callback, error_callback, packages)
                success_callback = success_callback or function() end -- stub out success and error
                error_callback = error_callback or function(result)
                    vim.notify(string.format("Error occured while installing %s. Error Code: %i, Error: %s", table.concat(packages, ' '), result.code, result.stderr))
                    return
                end
                local command = {"uv", "pip", "install", "--python", python_path, "--native-tls"}
                for _, package in ipairs(packages) do
                    table.insert(command, package)
                end
                vim.system(command, {}, function(result)
                    if result.code > 0 then
                        error_callback(result)
                    else
                        success_callback()
                    end
                end)
            end
        }
    }
    
    local package_manager = 
        vim.fn.executable('uv') == 1 and package_manager_map.uv
        or vim.fn.executable('pip') == 1 and package_manager_map.pip

    if not package_manager then
        -- If we cannot find a valid package manager, give up
        if vim.g.__miversen_warned_python_package_manager then
            vim.notify('Unable to locate a valid python package manager!', vim.log.levels.WARNING, {})
            vim.g.__miversen_warned_python_package_manager = true
        end
        return
    end

    vim.fn.mkdir(editor_dir, 'p')

    local needs_venv = true
    local needed_packages = {}
    -- Lets check to see what packages we need to install
    for lsp, _ in pairs(defaults) do
        if vim.fn.isdirectory(editor_venv) == 1 then
            needs_venv = false
            local lsp_path = string.format("%s/bin/%s", editor_venv, lsp)
            if vim.fn.filereadable(lsp_path) == 0 then
                table.insert(needed_packages, lsp)
            end
        else
            table.insert(needed_packages, lsp)
        end
    end
    if #needed_packages == 0 then
        -- Nothing to do, everything is already installed
        _success_callback()
        return
    end
    
    local _install = function(success_callback)
        vim.notify(string.format("Installing %s", table.concat(needed_packages, ' ')), vim.log.levels.DEBUG, {})
        package_manager.install(success_callback, nil, needed_packages)
    end

    if needs_venv then
        vim.notify(string.format("Creating venv \"%s\" for editor specific packages", editor_venv))
        package_manager.venv(
            function()
                _install(_success_callback)
            end
        )
    else
        _install(_success_callback)
    end
end

local project_root = vim.fs.root(0, project_root_markers)
local python_lsps = {}
-- If we find an lsp we have marked with _is_lsp, then we will set this to true
-- and we won't consider loading up the system lsp (if its available)
local found_geniune_lsp = false

if project_root then
    vim.notify(string.format("Python project root located at %s", project_root), vim.log.levels.DEBUG, {})
else
    vim.notify("Unable to locate python project root", vim.log.levels.DEBUG, {})
end

local venv_root = vim.fs.root(0, known_venvs)

local venv = ""
for _, known_venv in ipairs(known_venvs) do
    local search_path = string.format("%s/**", venv_root)
    vim.notify(string.format("Searching for %s in %s", known_venv, search_path), vim.log.levels.DEBUG)
    local _venv = vim.fn.finddir(known_venv, search_path)
    if _venv then
        venv = _venv
        break
    end
end


local function replace_variables_in_lsp_config(lsp_config, variables)
    for key, value in pairs(variables) do
        for lsp_config_key, lsp_config_value in pairs(lsp_config) do
            if type(lsp_config_value) == 'table' then
                replace_variables_in_lsp_config(lsp_config_value, variables)
            else if type(lsp_config_value) == 'string' and string.match(lsp_config_value, value.pattern) then
                    lsp_config[lsp_config_key] = string.gsub(lsp_config_value, value.pattern, value.replacement)
                end
            end
        end
    end
end

local function activate_lsps(_lsps)
    for _, lsp_name in ipairs(_lsps) do
        _G.__miversen_config.lsp.activate(lsp_name, lsps[lsp_name])
    end
end


if venv:len() > 0 then
    vim.notify(string.format("Found venv %s", venv), vim.log.levels.DEBUG, {})
    local bin_path = string.format("%s/bin", venv)

    -- Lets check to see if there are any known lsps in the virtual environment
    for lsp_name, lsp_config in pairs(lsps) do
        local lsp = string.format("%s/%s/%s", project_root, bin_path, lsp_name)
        vim.notify(string.format("Checking %s to see if %s exists", lsp, lsp_name), vim.log.levels.DEBUG, {})
        if vim.fn.filereadable(lsp) == 1 then
            local replacement_vars = {
                BIN_PATH = {
                    pattern = '%%BIN_PATH',
                    replacement = lsp
                },
                VENV_PATH = {
                    pattern = '%%VENV_PATH',
                    replacement = string.format("%s/%s", project_root, venv)
                }
            }
            replace_variables_in_lsp_config(lsps[lsp_name], replacement_vars)
            if lsp_config._is_lsp then
                found_geniune_lsp = true
            end
            table.insert(python_lsps, lsp_name)
        end
    end
    vim.schedule(function() activate_lsps(python_lsps) end)
end

if not found_geniune_lsp then
    vim.notify("Unable to locate lsp in project, setting up system lsp", vim.log.levels.DEBUG, {})
    local function complete()
        local _lsps = {}
        for lsp_name, _ in pairs(defaults) do
            local replacement_vars = {
                BIN_PATH = {
                    pattern = '%%BIN_PATH',
                    replacement = string.format("%s/bin/%s", editor_venv, lsp_name)
                },
                VENV_PATH = {
                    pattern = '%%VENV_PATH',
                    replacement = string.format("%s/%s", project_root, venv)
                }
            }
            replace_variables_in_lsp_config(lsps[lsp_name], replacement_vars)
            table.insert(_lsps, lsp_name)
        end
        vim.schedule(function() activate_lsps(_lsps) end)
    end
    install_local_lsp(complete)
end


_G.__miversen_lsp_python_setup = true

-- if venv:len() == 0 then
--     -- We should probably complain that we can't find a venv for this project
--     -- It is probably worth checking if there is a global lsp we can use
--     return
-- end


-- local local_dir = jit.os ~= 'Windows' and '.local/bin/lsps' or 'AppData/local/bin/lsps'
-- local python_language_servers = string.format("%s/%s/python_language_servers", uv.os_homedir(), local_dir)
--
-- local os_map = {
--     Linux = 'linux',
--     darwin = 'darwin',
--     Windows = 'win32'
-- }
--
--
--
-- -- -- We should see if the project root we are in contains a virtual environment already and just use that if it does exist
-- -- --
-- -- local package_manager_map = {
-- --     pip = {
-- --         venv = function()
-- --             local command = {"python3", "-m", "venv", pyrefly_venv}
-- --             vim.system(command, {}, function(result)
-- --
-- --             end)
-- --         end,
-- --         install = function()
-- --
-- --         end
-- --     },
-- --     uv = {
-- --         venv = function()
-- --             local command = {"uv", "venv", pyrefly_venv}
-- --             vim.system(command, {}, function(result)
-- --
-- --             end)
-- --         end,
-- --         install = function()
-- --             local command = {"source", pyrefly_venv, "&&", "uv", "pip", "install", "--native-tls", "pyrefly"}
-- --         end
-- --     }
-- -- }
-- --
-- -- local pyrefly_parent = string.format("%s/pyrefly/", python_language_servers)
-- --
-- -- local package_manager = 
-- --     vim.fn.executable('uv') == 1 and package_manager_map.uv
-- --     or vim.fn.executable('pip') == 1 and package_manager_map.pip
-- --
-- -- if not package_manager and not vim.g.__miversen_warned_python_package_manager then
-- --     vim.notify('Unable to locate a valid python package manager!', vim.log.levels.WARNING, {})
-- --     vim.g.__miversen_warned_python_package_manager = true
-- -- end
-- --
-- -- local needs_install = false
-- --
-- -- if vim.fn.isdirectory(python_language_servers) == 0 then
-- --     vim.fn.mkdir(python_language_servers, 'p')
-- --     needs_install = true
-- -- end
-- --
-- -- if vim.fn.isdirectory(pyrefly_parent) == 0 then
-- --     vim.fn.mkdir(pyrefly_parent, 'p')
-- --     needs_install = true
-- -- end
-- --
-- -- if needs_install and not vim.g.__miversen_installing_pyrefly then
-- --     vim.notify('Installing pyrefly', vim.log.levels.INFO, {})
-- --     package_manager.venv()
-- --     package_manager.install('pyrefly')
-- -- end
-- --
-- --
-- --
-- -- -- -- Check to see if pyrefly's venv is setup
-- -- -- if vim.fn.isdirectory(pyrefly_venv) == 0 and not vim.g.__miversen_setup_pyrefly then
-- -- --     vim.g.__miversen_setup_pyrefly = true
-- -- --     vim.notify("Pyrefly not found, setting it up now", vim.log.levels.INFO, {})
-- -- --     local pyrefly_parent = string.format("%s/../", pyrefly_venv)
-- -- --     if vim.fn.isdirectory(pyrefly_parent) == 0 then
-- -- --         vim.fn.mkdir(pyrefly_parent, 'p')
-- -- --     end
-- -- --     package_manage.venv()
-- -- -- end

