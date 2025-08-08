-- lsps/init.lua
local lsp_manager = require("scripts.lsp")

local M = {}

---@type Lsp[]
M._lsps = {}

local lsp_dir = string.format("%s/lua/lsps", vim.fn.stdpath("config"))
local lsp_files = vim.fn.glob(lsp_dir .. "/*.lua", false, true)

for _, file_path in ipairs(lsp_files) do
    local filename = vim.fn.fnamemodify(file_path, ":t:r")

    if filename == "init" then
        -- Skip init.lua (this file)
        goto continue
    end
    local success, lsp_module = pcall(require, "lsps." .. filename)

    if success == false then
        vim.notify(string.format("Failed to load LSP module %s: %s", filename, lsp_module), vim.log.levels.ERROR)
        goto continue
    end
    if type(lsp_module) ~= "table" then
        vim.notify(string.format("LSP module %s did not return a table", filename), vim.log.levels.WARN)
        goto continue
    end
    -- Wrap the lsp_module in a table so we can iterate
    local _lsps = lsp_module.name and { lsp_module } or lsp_module
    for _, _lsp in ipairs(_lsps) do
        table.insert(M._lsps, _lsp)
        -- Group lsps by their filetypes so we can more easily manipulate them
        if _lsp.config.filetypes then
            for _, filetype in ipairs(_lsp.config.filetypes) do
                if M[filetype] == nil then
                    M[filetype] = {}
                end
                M[filetype][_lsp.name] = _lsp
            end
        end
    end
    ::continue::
end

for _, lsp in pairs(M._lsps) do
    vim.api.nvim_create_autocmd("FileType", {
        pattern = lsp.config.filetypes or {},
        callback = function(ev)
            lsp_manager.register(lsp.config.filetypes, lsp)
        end,
        desc = string.format("Auto lsp handler for %s", lsp.name),
        once = true -- There is never a reason to have this fire more than once ever
    })
end
::continue::

return M
