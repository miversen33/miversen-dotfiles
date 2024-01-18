vim.g.neo_tree_remove_legacy_commands = 1
-- Setting Basic Vim Settings
local function vim_settings()
    local undo_dir = vim.fn.stdpath('cache') .. "/undo/"
    vim.fn.mkdir(undo_dir, 'p')
    -- Fixes wezterm artifacts in muxer :(
    vim.opt.termsync = false
    vim.opt.undofile  = true
    vim.opt.splitkeep = 'screen'
    vim.opt.undodir       = undo_dir
    vim.opt.fillchars:append(',eob: ')
    vim.opt.scrolloff     = 3
    vim.opt.undolevels    = 1000
    vim.opt.undoreload    = 10000
    vim.opt.mouse         = 'a'
    vim.opt.guicursor     =
    'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175'
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
    vim.opt.background     = 'dark'
    vim.opt.hlsearch       = true
    vim.opt.ignorecase     = true
    vim.opt.incsearch      = true
    vim.opt.hidden         = true
    vim.opt.foldmethod     = 'indent'
    vim.opt.foldlevel      = 99
    vim.opt.list           = true
    -- vim.opt.spell         = true
    vim.opt.cmdheight      = 0
    vim.opt.listchars      = {
        tab = '-->',
        multispace = ' ',
        -- nbsp=' ',
        trail = '',
        extends = '⟩',
        precedes = '⟨'
    }
    vim.g.showbreak        = '↪'
    vim.opt.cursorline     = true
    vim.opt.splitright     = true
    vim.opt.splitbelow     = true
    vim.opt.expandtab      = true
    vim.opt.smarttab       = true
    vim.opt.completeopt    = 'longest,preview,menuone,noselect'
    vim.g.vimsyn_embed     = 'lPrj'
    vim.opt.updatetime     = 2000
    vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
    for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do vim.api.nvim_set_hl(0, group, {}) end
    local _print = _G.print
    local clean_string = function(...)
        local args = { n = select("#", ...), ... }
        local formatted_args = {}
        for i = 1, args.n do
            local item = select(i, ...)
            if not item then item = 'nil' end
            local t_item = type(item)
            if t_item == 'table' or t_item == 'function' or t_item == 'userdata' then
                item = vim.inspect(item)
            else
                item = string.format("%s", item)
            end
            table.insert(formatted_args, item)
        end
        return table.concat(formatted_args, ' ')
    end
    _G.print = function(...)
        _print(clean_string(...))
    end
    local uv = vim.uv or vim.loop
    _G.os_sep = uv.os_uname().sysname:lower():match('windows') and '\\' or '/' -- \ for windows, mac and linux both use \
    _G.__miversen_border_color = "#806d9c"
    _G.__miversen_augroup = "miversen_config_augroup"
    vim.api.nvim_create_augroup(_G.__miversen_augroup, { clear = true })
end

local function setup_basic_keycommands()
    local function save()
        local filename = vim.fn.expand("%:t")
        local write_success, error_message = pcall(vim.api.nvim_command, ':w')
        if write_success then
            vim.notify(string.format("Saving %s", filename), vim.log.levels.INFO)
        else
            vim.notify(string.format("Error while saving %s\n\t%s", filename, error_message), vim.log.levels.ERROR)
        end
        local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
        vim.api.nvim_feedkeys(esc, 'm', false)
    end
    local jump_to_next_word_pattern = [[\v['"({[< ]@<=(\w)|^(\w)|([]'"\>)}]\.)@<=(\w)|(['"])@<=([][(){}.,;])(['"])]]

    -- Keymappings
    vim.keymap.set('n', '<Space>', '<Nop>', { silent = true })
    vim.g.mapleader = ' '
    vim.g.maplocalleader = ','

    vim.keymap.set('n', 'AA', 'ggVG', { silent = true })
    vim.keymap.set('v', 'AA', 'ggV', { silent = true })
    vim.keymap.set('n', '<A-Down>', 'ddjP', { silent = true })
    vim.keymap.set('n', '<A-Up>', 'ddkP', { silent = true })
    vim.keymap.set('n', '<C-x>', 'dd', { silent = true })
    vim.keymap.set('n', '<C-X>', 'ddO', { silent = true })
    vim.keymap.set('i', '<S-Tab>', '<esc>:<<CR>i', { silent = true })
    vim.keymap.set('n', '<S-Tab>', ':<<CR>', { silent = true })
    vim.keymap.set('n', '<Up>', 'gk', { silent = true })
    vim.keymap.set('n', '<Down>', 'gj', { silent = true })
    vim.keymap.set('v', '<Up>', 'gk', { silent = true })
    vim.keymap.set('v', '<Down>', 'gj', { silent = true })
    vim.keymap.set('v', '<Tab>', ':><CR>', { silent = true })
    vim.keymap.set('v', '<S-Tab>', ':<<CR>', { silent = true })
    vim.keymap.set('n', '<C-Del>', 'dw', { silent = true })
    vim.keymap.set('i', '<C-Del>', '<esc>ldwi', { silent = true })
    vim.keymap.set({"n", "i", "v"}, "<C-s>", save, {silent = true})
    vim.keymap.set('n', 'zz', 'zc', { silent = true })     -- Fold
    vim.keymap.set('n', 'zZ', 'zo', { silent = true })     -- Unfold
    vim.keymap.set({'n', 'v'}, 'e', function()
        vim.fn.search(jump_to_next_word_pattern)
    end)
    vim.keymap.set({'n', 'v'}, 'E', function()
    --(word) backwards
      vim.fn.search(jump_to_next_word_pattern, 'b')
    end)
end

local function setup_advanced_keycommands()
    if vim.g.__debug_config then
        vim.notify("Avoiding Advanced Keycommands as we are in debug mode")
        return
    end

    local success, hydra = pcall(require, "hydra")
    if not success then
        print("Unable to locate hydra!")
        return
    end

    local function do_exit()
        vim.cmd('noh')
        local success, notify, hover, specs, cmp = nil, nil, nil, nil, nil
        success, notify = pcall(require, "notify")
        if success then
            notify.dismiss()
        end
        success, hover = pcall(require, "pretty_hover")
        if success then
            hover.close()
        end
        success, specs = pcall(require, "specs")
        if success then
            specs.show_specs()
        end
        success, _ = pcall(require, "fidget")
        if success then
            vim.cmd('Fidget clear')
        end
        success, cmp = pcall(require, 'cmp')
        if success then
            cmp.close()
        end
        local key = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
        vim.api.nvim_feedkeys(key, 'n', false)
    end
    vim.keymap.set({ 'n', 'i', 'v', 's', 'c', 'x' }, '<Esc>', do_exit, { silent = true })
    vim.keymap.set('n', '<C-t>', ':CFloatTerm<CR>', { silent = true })
    vim.keymap.set({'n', 'v'}, '<C-f>', function() require("telescope").extensions.live_grep_args.live_grep_args() end, { silent = true})
    vim.keymap.set('t', '<C-t>', '<C-\\><C-n>:CFloatTerm<CR>', { silent = true })
    vim.keymap.set('n', '<C-p>', ':CSplitTerm vertical<CR>', { silent = true })
    vim.keymap.set('t', '<C-p>', '<C-\\><C-n>:CSplitTerm vertical<CR>', { silent = true })
    vim.keymap.set('n', '<C-u>', ':CSplitTerm horizontal<CR>', { silent = true })
    vim.keymap.set('t', '<C-u>', '<C-\\><C-n>:CSplitTerm horizontal<CR>', { silent = true })
    vim.keymap.set('n', '<C-_>', ':lua require("Comment.api").toggle.linewise()<CR>', { silent = true })
    vim.keymap.set('i', '<C-_>', '<ESC>:lua require("Comment.api").toggle.linewise()<CR>i', { silent = true })
    vim.keymap.set('x', '<C-_>', '<ESC>:lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>',
        { silent = true })
    vim.keymap.set('n', '<C-h>', ":lua require('smart-splits').move_cursor_left()<CR>", { silent = true })
    vim.keymap.set('n', '<C-j>', ":lua require('smart-splits').move_cursor_down()<CR>", { silent = true })
    vim.keymap.set('n', '<C-k>', ":lua require('smart-splits').move_cursor_up()<CR>", { silent = true })
    vim.keymap.set('n', "<C-l>", ":lua require('smart-splits').move_cursor_right()<CR>", { silent = true })
    vim.keymap.set('t', '<C-h>', "<C-\\><C-n>:lua require('smart-splits').move_cursor_left()<CR><ESC>", { silent = true })
    vim.keymap.set('t', '<C-j>', "<C-\\><C-n>:lua require('smart-splits').move_cursor_down()<CR><ESC>", { silent = true })
    vim.keymap.set('t', '<C-k>', "<C-\\><C-n>:lua require('smart-splits').move_cursor_up()<CR><ESC>", { silent = true })
    vim.keymap.set('t', "<C-l>", "<C-\\><C-n>:lua require('smart-splits').move_cursor_right()<CR><ESC>", { silent = true })
    vim.keymap.set("n", "<S-h>", "<Plug>(cokeline-focus-prev)", { silent = true })
    vim.keymap.set("n", "<S-l>", "<Plug>(cokeline-focus-next)", { silent = true })
    vim.keymap.set("n", '<C-Down>', ':MoveLine(1)<CR>', { silent = true })
    vim.keymap.set("n", '<C-Up>', ':MoveLine(-1)<CR>', { silent = true })
    vim.keymap.set("i", '<C-Up>', '<ESC>:MoveLine(-1)<CR>i', { silent = true })
    vim.keymap.set("i", '<C-Down>', '<ESC>:MoveLine(1)<CR>i', { silent = true })
    vim.keymap.set("v", '<C-Down>', ':MoveBlock(1)<CR>', { silent = true })
    vim.keymap.set("v", '<C-Up>', ':MoveBlock(-1)<CR>', { silent = true })
    vim.keymap.set("v", '<C-Left>', ':MoveHBlock(-1)<CR>', { silent = true })
    vim.keymap.set("v", '<C-Right>', ':MoveHBlock(1)<CR>', { silent = true })
    vim.keymap.set("n", "<C-Enter>", ":Glance definitions<CR>", { silent = true })
    vim.keymap.set("t", "<S-space>", "<space>", { silent = true })
    vim.keymap.set("t", "<S-BS>", "<BS>", { silent = true })
    vim.api.nvim_set_keymap('n', 'n', [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'N', [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], { noremap = true, silent = true })
    -- vim.keymap.set("n", '/',     ':lua require("searchbox").incsearch({modifier = "disabled"})<CR>', {silent = true})
    -- vim.keymap.set("n", 'r',     ':lua require("searchbox").replace({confirm = "menu"})<CR>', {silent = true})
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
    if vim.g.__debug_config then
        vim.notify("Avoiding Plugins as we are in debug mode")
        return
    end
    _G.__miversen_config_excluded_filetypes_array = {
        "lsp-installer",
        "lspinfo",
        "Outline",
        "lazy",
        "help",
        "packer",
        "netrw",
        "qf",
        "dbui",
        "Trouble",
        "fugitive",
        "floaterm",
        "spectre_panel",
        "spectre_panel_write",
        "checkhealth",
        "man",
        "dap-repl",
        "toggleterm",
        "neo-tree",
        "ImportManager",
        "aerial",
        "TelescopePrompt",
        "NetmanLogs",
        "neo-tree-popup",
        "",
    }
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    local lazyurl = "https://github.com/folke/lazy.nvim.git"
    local lazybranch = "stable"
    if not vim.loop.fs_stat(lazypath) then
        print("Initializing Lazy Plugin Manager")
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            lazyurl,
            string.format("--branch=%s", lazybranch),
            lazypath
        })
    end
    vim.opt.rtp:prepend(lazypath)
    local success, lazy_or_err = pcall(require, "lazy")
    if not success then
        vim.notify("Unable to load lazy plugin manager, received error")
        print(lazy_or_err)
        return
    end
    local lazy = lazy_or_err
    local lazy_opts = {
        dev = {
            path = "~/git",
            patterns = { "miversen33", "nvim-island" },
            fallback = true
        },
        change_detection = {
            enabled = false,
            notify = true
        },
        ui = {
            border = "rounded",
        }
    }
    lazy.setup("plugins", lazy_opts)
        -- Setting up some basic highlight groups
    vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#004b72", fg = "NONE" })
    vim.api.nvim_set_hl(0, "Pmenu", { fg = "#C5CDD9", bg = "NONE" })
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = _G.__miversen_border_color})
    vim.api.nvim_set_hl(0, "NormalFloat", {fg="NONE", bg="NONE"})
    -- vim.api.nvim_set_hl(0, "ColorColumn", {fg = "#97E004"})
end

vim_settings()
setup_basic_keycommands()
setup_config_watcher()
check_if_debug()
setup_plugins()
setup_advanced_keycommands()
