local markdown_opts = {}

---@module "lazy"
---@type LazySpec
return {
    'MeanderingProgrammer/render-markdown.nvim',
    opts = markdown_opts,
    ft = { 'markdown' },
    -- enabled = false,
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
}
