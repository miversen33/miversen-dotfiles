vim.g.neo_tree_remove_legacy_commands = 1
-- Setting Basic Vim Settings
local function vim_settings()
    -- local undo_dir = vim.fn.stdpath('cache') .. "/undo/"
    -- vim.fn.mkdir(undo_dir, 'p')
    -- Fixes wezterm artifacts in muxer :(
    vim.opt.termsync = false
    vim.opt.undofile  = true
    vim.opt.splitkeep = 'screen'
    -- vim.opt.undodir       = undo_dir
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
        vim.notify(string.format("Saving %s", filename))
        vim.api.nvim_command(':w')
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
    vim.keymap.set('n', '<C-s>', save, { silent = true })
    vim.keymap.set('i', '<C-s>', save, { silent = true })
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
    local cmd = require("hydra.keymap-util").cmd
    hydra({
        name = "Search Commands",
        mode = { "n", "v" },
        hint = [[
        Search Commands
        ^
        _d_: Search Directory           _w_: Search with highlighted word
        _/_: Search File                _f_: Telescope Search
        ^
        ^ ^                              _q_/_<Esc>_: Exit Hydra
        ]],
        config = {
            color = 'teal',
            invoke_on_body = true,
            hint = {
                type = 'window',
                position = 'bottom',
                float_opts = { border = 'rounded', },
                show_name = true
            }
        },
        body = 'f',
        heads = {
            { "d",     cmd 'lua require("spectre").open()<CR>',                          { desc = "Search", silent = true } },
            { "w",     cmd 'lua require("spectre").open_visual({select_word=true})<CR>',
                                                                                             { desc = "Search word",
                    silent = true } },
            { "f",     cmd 'Telescope live_grep',                                        { desc =
            "Fuzzy Search with Telescope", silent = true } },
            { "/",     cmd 'lua require("spectre").open_file_search()<CR>',              { desc = "Search File",
                silent = true } },
            { "q",     nil,                                                              { desc = "quit", exit = true,
                nowait = true } },
            { "<Esc>", nil,                                                              { desc = "quit", exit = true,
                nowait = true } }
        }
    })
    hydra({
        name = "Repl Commands",
        mode = { "n", "i", "v" },
        hint = [[
        Repl Commands
        ^
        _<C-s>_: Send file to repl
        _<C-g>_: Restart Repl
        ^
        _<C-e>_: Exit Hydra
        ]],
        config = {
            color = "pink",
            invoke_on_body = true,
            hint = {
                type = "window",
                position = "top-right",
                float_opts = { border = 'rounded', },
                show_name = true
            },
        },
        body = "<C-e>",
        heads = {
            { "<C-g>",
                function()
                    require("sniprun").reset()
                end,
                {
                    desc = "Restarts Repl",
                    silent = true
                }
            },
            { "<C-s>",
                function()
                    vim.cmd('%SnipRun')
                end,
                {
                    desc = "Writes current file to repl",
                    silent = true
                }
            },
            { "<C-e>", nil, { desc = "quit", exit = true, nowait = true } },
        }
    })
    hydra({
        name = "Quick/Common Commands",
        mode = { "n" },
        hint = [[
    Quick/Common Commands
    ^
    _f_: Show Filesystem            _t_: Show Terminal (float)      _x_: Open Quickfix
    _s_: Buffer Fuzzy Search        _'_: Open Symbols Outline       _o_: Open Horizontal Terminal
    _p_: Open Vertical Terminal     _h?_: Show Help Tags            _c?_: Show Vim Commands
    _m?_: Show Man Pages            _l_: Open Location List
    ^
    ^ ^                              _q_/_<Esc>_: Exit Hydra
    ]],
        config = {
            color = 'teal',
            invoke_on_body = true,
            hint = {
                type = "window",
                position = "bottom",
                float_opts = { border = 'rounded', },
                show_name = true,
            }
        },
        body = "t",
        heads = {
            { "f",     cmd 'Neotree filesystem reveal',                           { desc =
            "Opens Neotree File Explorer", silent = true } },
            { "h?",    cmd "Telescope help_tags",                                       { desc = "Open Help Tags",
                silent = true } },
            { "c?",    cmd "Telescope commands",                                        { desc =
            "Open Available Telescope Commands", silent = true } },
            { "s",     cmd "Telescope current_buffer_fuzzy_find skip_empty_lines=true",
                                                                                            { desc =
                "Fuzzy find in current buffer", silent = true } },
            { "'",     cmd "AerialToggle!",                                             { desc = "Opens Symbols Outline",
                exit = true, silent = true } },
            -- {"k?",     ":lua require('telescope.builtin').keymaps()<CR>", {desc = "Open Neovim Keymaps", silent = true}},
            { "m?",    cmd "Telescope man_pages",                                       { desc = "Opens Man Pages",
                silent = true } },
            { "x",     cmd "TroubleToggle quickfix",                                    { desc = "Opens Quickfix",
                silent = true } },
            { "l",     cmd "TroubleToggle loclist",                                     { desc = "Opens Location List",
                silent = true } },
            { "t",     cmd "CFloatTerm",                                                { desc = "Floating Term",
                silent = true } },
            { "o",     cmd "CSplitTerm horizontal",                                     { desc = "Horizontal Term",
                silent = true } },
            { "p",     cmd "CSplitTerm vertical",                                       { desc = "Vertical Term",
                silent = true } },
            { "q",     nil,                                                             { desc = "quit", exit = true,
                nowait = true } },
            { "<Esc>", nil,                                                             { desc = "quit", exit = true,
                nowait = true } }
        }
    })
    hydra({
        name = "Terminal Commands",
        mode = { "t" },
        config = {
            color = "red",
            invoke_on_body = true,
            hint = {
                type = "window",
                position = "top",
                float_opts = { border = 'rounded', },
                show_name = true
            },
        },
        hint = [[
    Terminal Commands
    ^
    _<Left>_: Resize Window Left          _<Right>_: Resize Window Right     _<Up>_: Resize Window Up     _<Down>_: Resize Window Down
    _h_: Move Focus Left                 _j_: Move Focus Down               _k_: Move Focus Up             _l_: Move Focus Right
    _z_: Maximize current pane           _<C-Space>_: Escape Terminal Mode  _x_: Close Terminal
    ^
    ^ ^                                                      _q_/_<Esc>_: Exit Hydra
    ]],
        body = "<C-Space>",
        heads = {
            { "<Left>",    cmd "lua require('smart-splits').resize_left()i",
                                                                                      { desc = "Resize Pane/Window Left",
                    silent = true } },
            { "<Right>",   cmd "lua require('smart-splits').resize_right()",
                                                                                      { desc = "Resize Pane/Window Right",
                    silent = true } },
            { "<Up>",      cmd "lua require('smart-splits').resize_up()",         { desc = "Resize Pane/Window Up",
                silent = true } },
            { "<Down>",    cmd "lua require('smart-splits').resize_down()",
                                                                                      { desc = "Resize Pane/Window Down",
                    silent = true } },
            { "h",         cmd "lua require('smart-splits').move_cursor_left()",
                                                                                      { desc = "Move Focus Left",
                    exit = true, silent = true } },
            { "j",         cmd "lua require('smart-splits').move_cursor_down()",
                                                                                      { desc = "Move Focus Down",
                    exit = true, silent = true } },
            { "k",         cmd "lua require('smart-splits').move_cursor_up()",
                                                                                      { desc = "Move Focus Up",
                    exit = true, silent = true } },
            { "l",         cmd "lua require('smart-splits').move_cursor_right()",
                                                                                      { desc = "Move Focus Right",
                    exit = true, silent = true } },
            { "z",         cmd "lua require('maximize').toggle()",
                                                                                      { desc = "Maximize current pane",
                    exit = true, silent = true } },
            { "<C-Space>", "<C-\\><C-n>",                                         { desc = "Escape Terminal Mode",
                exit = true } },
            { "x",         "<C-\\><C-n>:q<CR>",                                   { desc = "Close Terminal", exit = true } },
            { "q",         nil,                                                   { desc = "quit", exit = true,
                nowait = true } },
            { "<Esc>",     nil,                                                   { desc = "quit", exit = true,
                nowait = true } }
        }
    })
    hydra({
        name = "Helper Mode",
        mode = { "n" },
        config = {
            color = "pink",
            invoke_on_body = true,
            hint = {
                type = "window",
                position = "bottom-right",
                float_opts = { border = 'rounded', },
                show_name = true
            },
        },
        hint = [[
    LSP
    ^
    - _lf_: Format Buffer
    - _la_: Code Actions
    - _ls_: Show Definitions
    - _ld_: Show Diagnostics
    - _lw_: Show Workspace Diagnostics
    - _ln_: Rename
    ^
    Help
    - _hh_: Show Hover Doc
    - _he_: Show Declerations
    - _hD_: Show Type Definition
    - _hj_: Show Sig Help
    - _ho_: Show Implementation
    - _hr_: Show References
    ^
    DAP
    ^
    _dt_: Toggle UI
    ^
    _dd_: Toggle Breakpoint
    _dD_: Set Conditional Breakpoint
    _dc_: Continue on Break
    _dS_: Stop Debugger
    ^
    _dj_: Step out of code block
    _dk_: Step over code block
    _dl_: Step into code block
    _dL_: Launches DAP Server
    _dr_: Open DAP REPL
    ^
    Unit Tests
    _tt_: Toggle Unit Test Window
    _tr_: Run unit tests for file
    _ta_: Run all unit tests for project
    _tl_: Re-run last unit test
    _ts_: Stop all unit tests
    _td_: Run unit tests in DAP mode
    ^
    _;_/_q_/_<Esc>_: Exit Hydra
    ]],
        body = ";",
        heads = {
            { "ls",     cmd 'Glance definitions',                            { desc = "Show Definition", silent = true } },
            { "hh",     function() require("pretty_hover").hover() end,      { desc = "Show Hover Doc", silent = true } },
            { "ho",     cmd 'Glance implementations',                        { desc = "Show Implementations",
                silent = true } },
            { "hj",     vim.lsp.buf.signature_help,                          { desc = "Show Sig Help", silent = true } },
            { "hr",     cmd 'Glance references',                             { desc = "Show References", silent = true } },
            { "ln",     vim.lsp.buf.rename,                                  { desc = "Rename Object Under Cursor",
                silent = true } },
            { "lf",     function() vim.lsp.buf.format({ async = true }) end, { desc = "Format Buffer", silent = true } },
            { "la",     vim.lsp.buf.code_action,                             { desc = "Show Code Actions", silent = true } },
            { "ld",     cmd 'TroubleToggle document_diagnostics',            { desc = "Show Diagnostics", silent = true } },
            { "lw",     cmd 'TroubleToggle workspace_diagnostics',           { desc = "Show Workspace Diagnostics",
                silent = true } },
            { "hD",     cmd 'Glance type_definitions',                       { desc = "Show Type Definition",
                silent = true } },
            { "he",     vim.lsp.buf.decleration,                             { desc = "Show Declerations", silent = true } },
            { "dt", cmd "lua require('dapui').toggle()",                                  { desc = "Toggles the Dap UI",
                silent = true } },
            { "dd", cmd "lua require('dap').toggle_breakpoint()",                         { desc = "Set Breakpoint",
                silent = true } },
            { "dD", cmd "lua require('dap').set_breakpoint(vim.fn.input('Condition: '))",
                                                                                             { desc =
                "Set conditional Breakpoint", silent = true } },
            { "dc", cmd "lua require('dap').continue()",                                  { desc = "Continue on break",
                silent = true } },
            { "dj", cmd "lua require('dap').step_out()",                                  { desc =
            "Step out of code block", silent = true } },
            { "dk", cmd "lua require('dap').step_over()",                                 { desc = "Step over code block",
                silent = true } },
            { "dl", cmd "lua require('dap').step_into()",                                 { desc = "Step into code block",
                silent = true } },
            { "dL", function()
                local filetype = vim.api.nvim_buf_get_option(0, 'filetype')
                local dap = require("dap")
                if filetype == '' then filetype = 'nil' end
                if dap and dap.launch_server and dap.launch_server[filetype] then
                    dap.launch_server[filetype]()
                else
                    print(string.format("No DAP Launch server configured for filetype %s", filetype))
                end
            end, { desc = "Launches Dap Server" } },
            -- { "dr", cmd "lua require('neotest').run.run()", { desc = "Run Unit Tests", silent = true }},
            { "dr",     cmd "lua require('dap').repl.open()", { desc = "Open Live REPL", silent = true } },
            { "dS",     cmd "lua require('dap').terminate({},{terminateDebuggee = true}, function() require('dap').close() end)",
                 { desc = "Stop Debugger", exit = true }
            },
            { "tt",     cmd "lua require('neotest').output_panel.toggle()", { desc = "Toggle Testing Output Panel" }},
            { "tr",     cmd 'lua require("neotest").run.run(vim.fn.expand("%"))', { desc = "Runs unit tests for current file"}},
            { "tl",     cmd 'lua require("neotest").run.run_last()', {desc = "Runs last unit test" }},
            { "ta",     cmd "lua require('neotest').run.run()", { desc = "Runs all unit tests" }},
            { "ts",     cmd "lua require('neotest').run.stop()", { desc = "Stops running unit tests"}},
            { "td",     cmd "lua require('neotest').run.run({strategy = 'dap'})", { desc = "Runs unit tests in debug mode" }},
            { ";",     nil,                                                 { desc = "quit", exit = true, nowait = true } },
            { "q",     nil,                                                 { desc = "quit", exit = true, nowait = true } },
            { "<Esc>", nil,                                                 { desc = "quit", exit = true, nowait = true } }
        }
    })

    local function do_exit()
        vim.cmd('noh')
        local success, notify, hover, specs = nil, nil, nil, nil
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
        local key = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
        vim.api.nvim_feedkeys(key, 'n', false)
    end

    vim.keymap.set({ 'n', 'i', 'v', 's', 'c', 't', 'x' }, '<Esc>', do_exit, { silent = true })
    vim.keymap.set('n', '<C-t>', ':CFloatTerm<CR>', { silent = true })
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
    vim.keymap.set("n", "<S-j>", "<Plug>(cokeline-switch-prev)", { silent = true })
    vim.keymap.set("n", "<S-k>", "<Plug>(cokeline-switch-next)", { silent = true })
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
