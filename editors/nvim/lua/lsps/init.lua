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
        lsp_manager.register(_lsp.config.filetypes and _lsp.config.filetypes or {}, _lsp)
    end
    ::continue::
end

return M
