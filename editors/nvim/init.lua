local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

-- Custom functions
local function map(kind, lhs, rhs, opts)
  vim.api.nvim_set_keymap(kind, lhs, rhs, opts)
end

vim.cmd([[
augroup illuminate_augroup
    autocmd!
    autocmd VimEnter * hi illuminatedWord cterm=underline gui=underline
augroup END]]
)

local silent_noremap = {noremap = true, silent = true}
local noremap = {noremap=true}

-- Keymappings
map('n', '<A-k',     ':m .+1<CR>==', silent_noremap)
map('n', '<A-i>',    ':m .-2<CR>==', silent_noremap)
map('n', '<A-Down>', ':m .+1<CR>==', silent_noremap)
map('n', '<A-Up>',   ':m .-2<CR>==', silent_noremap)
map('n', '<A-a>',    ':tabp<CR>:echo "Tab Left"<CR>' , noremap)
map('n', '<A-d>',    ':tabn<CR>:echo "Tab Right"<CR>', noremap)
map('n', '<A-j>',    ':bprevious<CR>:echo "Buffer Left"<CR>', noremap)
map('n', '<A-l>',    ':bnext<CR>:echo "Buffer Right"<CR>', noremap)
map('n', '<C-x>',    'dd', silent_noremap)
map('n', '<C-X>',    'ddO', silent_noremap)
map('n', '<C-j>',    '<C-W><C-h>:echo "Pane Left"<CR>', noremap)
map('n', '<C-l>',    '<C-W><C-l>:echo "Pane Right"<CR>', noremap)
map('n', '<C-i>',    '<C-W><C-k>:echo "Pane Up"<CR>', noremap)
map('n', '<C-k>',    '<C-W><C-j>:echo "Pane Down"<CR>', noremap)
map('n', '<C-s>',    ':w<CR> :echo "Saved File"<CR>', noremap)
map('i', '<C-s>',    '<esc>:w<CR> :echo "Saved File"<CR>', noremap)
map('n', '<C-f>',    '/', noremap)
map('i', '<C-f>',    '<esc>/', noremap)
map('', '<C-_>',    ':Commentary<CR>: .+1<CR>', silent_noremap)
map('i', '<C-_>',    '<esc>:Commentary<CR><CR>i', silent_noremap)

-- Options
vim.opt.number        = true
vim.opt.termguicolors = true
vim.opt.numberwidth = 2
vim.opt.wrap        = true
vim.opt.background  = 'dark'
vim.opt.hlsearch    = true
vim.opt.ignorecase  = true
vim.opt.incsearch   = true
vim.opt.hidden      = true
vim.opt.foldmethod  = 'indent'
vim.opt.foldlevel   = 99
vim.opt.list        = true
vim.opt.listchars   = 'tab:-->,space:·'
vim.opt.cursorline  = true
vim.opt.splitright  = true
vim.opt.splitbelow  = true
vim.o.completeopt   = 'menuone,noselect'
vim.cmd[[colorscheme hybrid_reverse]]
vim.g.airline_theme = 'deus'
vim.g['airline#extensions#tabline#enabled'] = 1
vim.g['airline#extensions#tabline#left_alt_sep'] = '>'
vim.g['airline#extensions#ale#enabled'] = 1
vim.g.lsp_diagnostics_enabled = 0
vim.g.airline_powerline_fonts = 1
vim.g.indent_guides_enable_on_vim_startup = 1
vim.g.Illuminate_highlightUnderCursor = 0
vim.g.Illuminate_ftblacklist = { 'netrw', }
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,resize,winpos,terminal"

-- Plugins
local use = require('packer').use
require('packer').startup(function()
  -- Neovim LSP
  use 'neovim/nvim-lspconfig'
  use 'williamboman/nvim-lsp-installer'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'saadparwaiz1/cmp_luasnip'
  use 'L3MON4D3/LuaSnip'
  
  -- Theme Plugins
  use 'vim-airline/vim-airline' -- Consider switching this to https://github.com/nvim-lualine/lualine.nvim since we are using neovim. Might as well make the full switch
  use 'vim-airline/vim-airline-themes'
  use 'kristijanhusak/vim-hybrid-material'
  use 'yunlingz/equinusocio-material.vim'

  -- Language Plugins
  use 'alaviss/nim.nvim'

  -- Utility Plugins
  use 'tpope/vim-commentary'
  use 'getomni/neovim'
  use 'nathanaelkane/vim-indent-guides'
  use 'RRethy/vim-illuminate'
  use 'liuchengxu/vista.vim'
  use {
      'rmagatti/auto-session',
      config = function()
      require('auto-session').setup {
        log_level = 'info',
        auto_session_suppress_dirs = {'~/', '~/Projects'}
    }
  end
  }
end)

-- Settings

local nvim_lsp = require('lspconfig')
local luasnip  = require('luasnip')
local cmp      = require('cmp')
require'lspconfig'.nimls.setup{}
-- require'lspconfig'.vimls.setup{}

local nvim_capabilities = vim.lsp.protocol.make_client_capabilities()
nvim_capabilities = require('cmp_nvim_lsp').update_capabilities(nvim_capabilities)

local lsps = { 'pyright', 'nimls', }
for _, lsp in ipairs(lsps) do
  nvim_lsp[lsp].setup {
    on_attach = function(client)
        require 'illuminate'.on_attach(client)
    end,
    capabilities = nvim_capabilities,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- require('lualine').setup{
  -- options = {
    -- theme = 'tokyonight',
  -- },
  -- sections = {lualine_c = {require('auto-session-library').current_session_name}}
-- }

