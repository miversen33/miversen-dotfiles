local M = {}

M.get_lsp_settings = function()
    return {
    -- This is a table that contains key,value pairs of language server settings.
    -- The name of the language server is the key, and its settings are the value (as another table)
    -- EG
    -- pyright = {
    --     root_dir = require('lspconfig/util').root_pattern('.git', 'setup.py', 'setup.cfg', 'pyproject.toml', 'requirements.txt') or vim.loop.cwd()
    -- },
    }
end

return M

