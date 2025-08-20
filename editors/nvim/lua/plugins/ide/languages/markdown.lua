---@type LazySpec
local markdown = {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
        completions = {
            lsp = { enabled = true },
            -- blink = { enabled = true }
        },
    },
}

return markdown
