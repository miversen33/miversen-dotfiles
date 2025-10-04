local project_root_markers = {
    "pyproject.toml", "requirements.txt", ".vscode", ".nvim", ".venv", ".git"
}

-- Returns the current projects venv or nil
---@return string?
local function get_project_venv()
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

-- Returns the editor venv or empty string if we can't find it
---@return string?
local function get_editor_venv()
    local lsp_dir = string.format("%s/miversen/lsps", vim.fn.stdpath('data'))
    local venv_dir = string.format("%s/python/venv", lsp_dir)
    if vim.fn.isdirectory(venv_dir) ~= 1 then
        -- The directory doesn't exist
        return
    end
    return venv_dir
end

---@return string?
local function get_venv()
    local project_venv = get_project_venv()
    if project_venv then
        return project_venv
    else
        return get_editor_venv()
    end
end

---@return boolean
local function has_uv()
    return vim.fn.executable("uv") == 1
end

---@type LazySpec
local python_dap = {
    "https://codeberg.org/mfussenegger/nvim-dap-python.git",
    ft = "python",
    config = function()
        ---@type string
        local setup_string
        local venv = get_venv()
        if has_uv() then
            setup_string = "uv"
        elseif venv then
            setup_string = venv
        else
            setup_string = "python3"
        end
        require("dap-python").setup(setup_string)
        vim.keymap.set('n', '<leader>bf', function()
                vim.notify("Starting python method debugger", vim.log.levels.INFO)
                require('dap-python').test_method()
            end,
            { desc = "Runs the python debugger on the method the cursor is currently in", buffer = true })
        vim.keymap.set('v', "<leader>bv", function()
                vim.notify("Starting python selection debugger", vim.log.levels.INFO)
                require('dap-python').debug_selection()
            end,
            { desc = "Runs the python debugger on the section", buffer = true })
    end
}

return python_dap
