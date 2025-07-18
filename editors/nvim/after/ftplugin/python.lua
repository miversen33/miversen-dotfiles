local uv = vim.uv or vim.loop
local jit = require("jit")

-- Python can _and probably should_ have its lsp as part of its project. Look there first

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

vim.g.__miversen_icon = {require("mini.icons").get('filetype', 'python')}
vim.g.__miversen_color = {require("mini.icons").get('filetype', 'python')}
vim.g.__miversen_color = vim.g.__miversen_color[2]

local project_root = vim.fs.root(0, project_root_markers)
if project_root then
    vim.notify(string.format("Python project root located at %s", project_root), vim.log.levels.DEBUG, {})
else
    vim.notify("Unable to locate python project root")
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

if venv:len() > 0 then
    -- We found a venv, we should use it
end

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

