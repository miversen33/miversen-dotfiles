-- Dependency Managment???
-- sudo apt-get install ripgrep universal-ctags
-- python3 -m pip install pyright # Even though pyright is doodoo with function params snippets, we are still probably going to use it since its better than jedi

-- Packer Bootstrapping
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

-- Custom Functions

-- Plugin setup
require('plugins')

-- Neovim Configurations
-- Create a generic "enable italics, enable bold, enable transparent" map so we can auto do that
-- for any themes we set
-- Also create a generic "theme_style" that we can set and apply because everyone having 
-- their own is so irritating
vim.log.level         = "warn"
vim.opt.number        = true
vim.opt.syntax        = 'enable'
vim.opt.termguicolors = true
vim.opt.tabstop       = 4
vim.opt.shiftwidth    = 4
vim.opt.softtabstop   = 4
vim.opt.numberwidth   = 2
vim.opt.wrap          = true
vim.opt.background    = 'dark'
vim.opt.hlsearch      = true
vim.opt.ignorecase    = true
vim.opt.incsearch     = true
vim.opt.hidden        = true
vim.opt.foldmethod    = 'indent'
vim.opt.foldlevel     = 99
vim.opt.list          = true
vim.g.showbreak       = '↪'
vim.opt.listchars     = {
  tab = '-->' , multispace='·', nbsp='␣',
  trail='•', extends='⟩', precedes='⟨'
}
-- vim.opt.listchars     = 'tab:-->,multispace:·,nbsp=␣,trail=•,extends=⟩, precedes=⟨'
vim.opt.cursorline    = true
vim.opt.splitright    = true
vim.opt.splitbelow    = true
vim.opt.expandtab     = true
vim.opt.smarttab      = true
vim.o.completeopt     = 'longest,preview,menuone,noselect'
-- vim.o.completeopt     = 'menuone,noselect'
-- vim.g.lsp_diagnostics_enabled = 0
-- vim.g.airline_powerline_fonts = 1
-- vim.g.indent_guides_enable_on_vim_startup = 1
-- vim.g.Illuminate_highlightUnderCursor = 0
-- vim.g.Illuminate_ftblacklist = { 'netrw', }
-- vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,resize,winpos,terminal"

-- Keymaps
require('keymaps')

-- Language Server Setup
local illuminate = require('illuminate')

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local lsp_on_attach = function(client)
  illuminate.on_attach(client)
end
-- We need to verify that we have everything needed for the language servers...
local language_servers = {
  pyright = {
    root_dir = require('lspconfig/util').root_pattern('.git', 'setup.py', 'setup.cfg', 'pyproject.toml', 'requirements.txt') or vim.loop.cwd()
  },
  perlls = {}
}

local lspconfig = require('lspconfig')
for language_server, language_server_config in pairs(language_servers) do
  local on_attach = language_server_config['on_attach']
  if(on_attach) then
    language_server_config['on_attach'] = function(client)
      lsp_on_attach(client)
      on_attach(client)
    end
  else
    language_server_config['on_attach'] = lsp_on_attach
  end
  language_server_config['capabilities'] = capabilities
  lspconfig[language_server].setup(language_server_config)
end

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
  update_in_insert = true
})