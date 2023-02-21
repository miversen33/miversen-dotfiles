-- Setting Basic Vim Settings
local function vim_settings()
    -- local undo_dir = vim.fn.stdpath('cache') .. "/undo/"
    -- vim.fn.mkdir(undo_dir, 'p')
    -- vim.opt.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
    vim.opt.undofile      = true
    -- vim.opt.undodir       = undo_dir
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
    vim.opt.showmode      = false
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
    -- vim.opt.spell         = true
    vim.opt.cmdheight     = 0
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
    vim.opt.completeopt   = 'longest,preview,menuone,noselect'
    vim.g.vimsyn_embed    = 'lPrj'
    vim.opt.updatetime    = 2000
end

local function setup_basic_keycommands()
    -- Keymappings
    vim.keymap.set('n', '<Space>',   '<Nop>', {silent = true})
    vim.g.mapleader = ' '

    vim.keymap.set('n', 'AA',       'ggVG', {silent = true})
    vim.keymap.set('v', 'AA',       'ggV', {silent = true})
    vim.keymap.set('n', '<A-Down>', 'ddjP', {silent = true})
    vim.keymap.set('n', '<A-Up>',   'ddkP', {silent = true})
    vim.keymap.set('n', '<C-x>',    'dd', {silent = true})
    vim.keymap.set('n', '<C-X>',    'ddO', {silent = true})
    vim.keymap.set('i', '<S-Tab>',  '<esc>:<<CR>i', {silent = true})
    vim.keymap.set('n', '<S-Tab>',  ':<<CR>', {silent = true})
    vim.keymap.set('n', '<Up>',     'gk', {silent = true})
    vim.keymap.set('n', '<Down>',   'gj', {silent = true})
    vim.keymap.set('v', '<Up>',     'gk', {silent = true})
    vim.keymap.set('v', '<Down>',   'gj', {silent = true})
    vim.keymap.set('v', '<Tab>',    ':><CR>', {silent = true})
    vim.keymap.set('v', '<S-Tab>',  ':<<CR>', {silent = true})
    vim.keymap.set('n', '<C-Del>',  'dw', {silent = true})
    vim.keymap.set('i', '<C-Del>',  '<esc>ldwi', {silent = true})
    vim.keymap.set('n', '<C-s>',    ':w<CR>:lua vim.notify(string.format("Saved %s", vim.fn.expand("%:t")), "info")<CR>', {silent=true})
    vim.keymap.set('i', '<C-s>',    '<esc>:w<CR>:lua vim.notify(string.format("Saved %s", vim.fn.expand("%:t")), "info")<CR>', {silent=true})
    vim.keymap.set('n', 'zz',       'zc', {silent = true}) -- Fold
    vim.keymap.set('n', 'zZ',       'zo', {silent = true}) -- Unfold
end

local function setup_config_watcher()
    -- TODO: Mike, setup a series of watcher for the entire configuration directory for neovim
end

local function check_if_debug()
    vim.g.__debug_config = vim.loop.os_getenv('DEBUG_NEOVIM_CONFIG')
    if vim.g.__debug_config then
        vim.notify("Running Neovim in Configuration Debug Mode!", "warn")
    end
end

local function setup_plugins()
    if not vim.g.__debug_config then
        local success, err = pcall(require, 'plugins')
        if not success then
            vim.notify("Unable to load plugins, received error")
            print(err)
        end
    end
end

local function setup_lsp()
    if not vim.g.__debug_config then

    end
end

vim_settings()
setup_basic_keycommands()
setup_config_watcher()
check_if_debug()
setup_plugins()
setup_lsp()
