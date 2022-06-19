-- Dependency Managment???
-- sudo apt-get install ripgrep universal-ctags clang clangd
-- python3 -m pip install pyright # Even though pyright is doodoo with function params snippets, we are still probably going to use it since its better than jedi
-- npm install -g vscode-langservers-extracted dockerfile-language-server-nodejs emmet-ls sql-language-server @tailwindcss/language-server svelte-language-server typescript typescript-language-server vim-language-server bash-language-server
-- yarn global add yaml-language-server
-- nimble install nimlsp
-- wget https://github.com/rust-analyzer/rust-analyzer/releases/download/2021-12-27/rust-analyzer-x86_64-unknown-linux-gnu.gz (set a location for this to be installed to)
-- wget https://github.com/sumneko/lua-language-server/releases/download/2.5.6/lua-language-server-2.5.6-linux-x64.tar.gz (set a location for this to be installed to)
-- TODO(Mike) (Setup java language server?)

local DEBUG = false

if not DEBUG then
    -- Packer Bootstrapping
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
      fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    end

    -- Custom Functions

    -- Plugin setup
    require('plugins')
end
local undo_dir = vim.fn.stdpath('cache') .. "/undo/"
vim.fn.mkdir(undo_dir, 'p')
-- Neovim Configurations
-- Create a generic "enable italics, enable bold, enable transparent" map so we can auto do that
-- for any themes we set
-- Also create a generic "theme_style" that we can set and apply because everyone having
-- their own is so irritating
vim.opt.undofile      = true
vim.opt.undodir       = undo_dir
vim.opt.fillchars:append(',eob: ')
vim.opt.undolevels    = 1000
vim.opt.undoreload    = 10000
vim.opt.mouse         = 'a'
vim.opt.whichwrap     = '<,>,[,]'
vim.opt.encoding      = 'UTF-8'
vim.log.level         = "warn"
vim.opt.number        = true
vim.opt.syntax        = 'enable'
vim.opt.termguicolors = true
vim.opt.tabstop       = 4
vim.opt.shiftwidth    = 4
vim.opt.softtabstop   = 4
vim.opt.numberwidth   = 2
vim.opt.wrap          = true
vim.opt.clipboard:append('unnamedplus')
vim.opt.background    = 'dark'
vim.opt.hlsearch      = true
vim.opt.ignorecase    = true
vim.opt.incsearch     = true
vim.opt.hidden        = true
vim.opt.foldmethod    = 'indent'
vim.opt.foldlevel     = 99
vim.opt.list          = true
vim.opt.listchars     = {
  tab = '-->',
  multispace=' ',
  -- nbsp=' ',
  trail='',
  extends='⟩',
  precedes='⟨'
}
vim.g.showbreak       = '↪'
vim.opt.cursorline    = true
vim.opt.splitright    = true
vim.opt.splitbelow    = true
vim.opt.expandtab     = true
vim.opt.smarttab      = true
vim.o.completeopt     = 'longest,preview,menuone,noselect'
vim.g.vimsyn_embed    = 'lPrj'
-- Keymaps
require('keymaps').setup(DEBUG)

if not DEBUG then
    -- Language Server Setup
    local illuminate = require('illuminate')

    local M = {}

    M.icons = {
      Class = " ",
      Color = " ",
      Constant = " ",
      Constructor = " ",
      Enum = "了 ",
      EnumMember = " ",
      Field = " ",
      File = " ",
      Folder = " ",
      Function = " ",
      Interface = "ﰮ ",
      Keyword = " ",
      Method = "ƒ ",
      Module = " ",
      Property = " ",
      Snippet = "﬌ ",
      Struct = " ",
      Text = " ",
      Unit = " ",
      Value = " ",
      Variable = " ",
    }

    function M.setup()
      local kinds = vim.lsp.protocol.CompletionItemKind
      for i, kind in ipairs(kinds) do
        kinds[i] = M.icons[kind] or kind
      end
    end

    vim.cmd [[autocmd ColorScheme * highlight NormalFloat guibg=#1f2335]]
    vim.cmd [[autocmd ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]]
    -- Would be kewl but we need to get this to _only_ fire if autocomplete is not present...
    -- vim.cmd [[autocmd CursorHold  <buffer> lua vim.lsp.buf.hover()]]
    -- vim.cmd [[autocmd CursorHoldI <buffer> lua vim.lsp.buf.hover()]]

    local handlers = {
      ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {border = 'rounded'}),
      ["textDocument/signatureHelp"] =  vim.lsp.with(vim.lsp.handlers.signature_help, {border = 'rounded' }),
    }

    local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
    local status, aerial = pcall(require, 'aerial')
    local _capabilities = vim.lsp.protocol.make_client_capabilities()
    local capabilities = require('cmp_nvim_lsp').update_capabilities(_capabilities)
    local lsp_on_attach = function(client, bufnr)
      illuminate.on_attach(client)
      if status then aerial.on_attach(client, bufnr) end
    end

    -- TODO(Mike): Consider maybe using null-ls?


    local ls_settings_available, _ = pcall(require, 'ls_settings')

    if ls_settings_available then
        local lspconfig = require('lspconfig')
        local language_servers = require('ls_settings').get_lsp_settings()
        for language_server, language_server_config in pairs(language_servers) do
            local on_attach = language_server_config['on_attach']
            if(on_attach) then
                language_server_config['on_attach'] = function(client, bufnr)
                    lsp_on_attach(client, bufnr)
                    on_attach(client, bufnr)
                end
            else
                language_server_config['on_attach'] = lsp_on_attach
            end
            language_server_config['capabilities'] = capabilities
            language_server_config['handlers'] = handlers
            lspconfig[language_server].setup(language_server_config)
        end
    end

    local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end

    vim.diagnostic.config({
      update_in_insert = true,
      virtual_text = {
        source = "always",
        prefix = '●'
      },
      float = {
        source = "always",
      },
    })
end
