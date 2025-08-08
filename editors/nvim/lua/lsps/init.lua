-- lsps/init.lua
local lsp_manager = require("scripts.lsp")

local M = {}

---@type Lsp[]
M.lsps = {}

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
    -- If the module returns a single LSP config, wrap it in an array
    if lsp_module.name then
        table.insert(M.lsps, lsp_module)
    else
        vim.list_extend(M.lsps, lsp_module)
    end
    ::continue::
end

-- Optional: Set up autocmds for all discovered LSPs
function M.setup()
    for _, lsp in ipairs(M.lsps) do
        if lsp.enable ~= false then -- Default to enabled unless explicitly disabled
            vim.api.nvim_create_autocmd("FileType", {
                pattern = lsp.config.filetypes or {},
                callback = function(ev)
                    lsp_manager.register(lsp.config.filetypes, lsp)
                end,
                desc = string.format("Auto lsp handler for %s", lsp.name),
                once = true -- There is never a reason to have this fire more than once ever
            })
        end
    end
end

return M
