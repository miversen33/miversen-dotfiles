import({'hydra', 'hydra.keymap-util'}, function(modules)
    local hydra = modules['hydra']
    local cmd = modules['hydra.keymap-util'].cmd
    hydra({
        name = "Quick/Common Commands",
        mode = {"n"},
        hint = [[
                                 Quick/Common Commands
^
 _f_: Show Filesystem            _t_: Show Terminal (float)      _T_: Open Quickfix
 _s_: Buffer Fuzzy Search        _d_: CWD Fuzzy Search           _'_: Open Symbols Outline
 _o_: Open Horizontal Terminal   _p_: Open Vertical Terminal     _y_: Open REPL
_h?_: Show Help Tags            _c?_: Show Vim Commands         _m?_: Show Man Pages
^
^ ^                              _q_/_<Esc>_: Exit Hydra
        ]],
        config = {
            color = 'teal',
            invoke_on_body = true,
            hint = {
                type = "window",
                position = "bottom",
                border = "rounded",
                show_name = true,
            }
        },
        body = "t",
        heads = {
            {"f",      cmd 'Neotree filesystem reveal right', {desc = "Opens Neotree File Explorer", silent = true}},
            {"h?",     cmd "Telescope help_tags", {desc = "Open Help Tags", silent = true}},
            {"c?",     cmd "Telescope commands", {desc = "Open Available Telescope Commands", silent = true}},
            {"s",      cmd "Telescope current_buffer_fuzzy_find skip_empty_lines=true", {desc = "Fuzzy find in current buffer", silent = true}},
            {"y",      cmd "IronRepl", {desc = "Repl", silent = true}},
            {"d",      cmd "lua require('telescope').extensions.live_grep_args.live_grep_args()", {desc = "Ripgrep CWD", silent = true}},
            {"'",       cmd "AerialToggle!", {desc = "Opens Symbols Outline", exit = true, silent = true}},
            -- {"k?",     ":lua require('telescope.builtin').keymaps()<CR>", {desc = "Open Neovim Keymaps", silent = true}},
            {"m?",     cmd "Telescope man_pages", {desc = "Opens Man Pages", silent = true}},
            {"T",      cmd "TroubleToggle", {desc = "Opens Diag Quickfix", silent = true}},
            {"t",      cmd "CFloatTerm", {desc = "Floating Term", silent = true}},
            {"o",      cmd "CFloatTerm horizontal", {desc = "Horizontal Term", silent = true}},
            {"p",      cmd "CFloatTerm vertical", {desc = "Vertical Term", silent = true}},
            {"q",      nil, {desc = "quit", exit = true, nowait = true}},
            {"<Esc>",  nil, {desc = "quit", exit = true, nowait = true}}
        }
    })
    hydra({
        name = "Navigation Commands",
        mode = {"n"},
        config = {
            color = "red",
            invoke_on_body = true,
            hint = {
                type = "window",
                position = "top",
                border = "rounded",
                show_name = true,
            }
        },
            hint = [[
                                                     Navigation Commands
^
_<Left>_: Resize Window Left     _<Right>_: Resize Window Right     _<Up>_: Resize Window Up     _<Down>_: Resize Window Down
     _u_: Move current tab left     _i_: Move current tab right        _z_: Maximize current pane
^
^ ^                                                 _q_/_<Esc>_: Exit Hydra
            ]],
        body = "<C-Space>",
        heads = {
            {"<Left>",  cmd "lua require('smart-splits').resize_left()",  {desc = "Resize Pane/Window Left", silent = true}},
            {"<Right>", cmd "lua require('smart-splits').resize_right()", {desc = "Resize Pane/Window Right", silent = true}},
            {"<Up>",    cmd "lua require('smart-splits').resize_up()",    {desc = "Resize Pane/Window Up", silent = true}},
            {"<Down>",  cmd "lua require('smart-splits').resize_down()",  {desc = "Resize Pane/Window Down", silent = true}},
            {"u",       "<Plug>(cokeline-switch-prev)", {desc = "Move current tab left", silent = true}},
            {"i",       "<Plug>(cokeline-switch-next)", {desc = "Move current tab right", silent = true}},
            {"z",       cmd "lua require('maximize').toggle()", {desc = "Maximize current pane", exit = true, silent = true}},
            {"q",       nil, {desc = "quit", exit = true, nowait = true}},
            {"<Esc>",   nil, {desc = "quit", exit = true, nowait = true}}
        }
    })
    hydra({
        name = "Terminal Commands",
        mode = {"t"},
        config = {
            color = "red",
            invoke_on_body = true,
            hint = {
                type = "window",
                position = "top",
                border = "rounded",
                show_name = true
            },
        },
            hint = [[
Terminal Commands
^
_<Left>_: Resize Window Left        _<Right>_: Resize Window Right     _<Up>_: Resize Window Up     _<Down>_: Resize Window Down
     _h_: Move Focus Left                 _j_: Move Focus Down            _k_: Move Focus Up             _l_: Move Focus Right
     _z_: Maximize current pane   _<C-Space>_: Escape Terminal Mode
^
^ ^                                                      _q_/_<Esc>_: Exit Hydra
            ]],
        body = "<C-Space>",
        heads = {
            {"<Left>",  cmd "lua require('smart-splits').resize_left()i",  {desc = "Resize Pane/Window Left", silent = true}},
            {"<Right>", cmd "lua require('smart-splits').resize_right()", {desc = "Resize Pane/Window Right", silent = true}},
            {"<Up>",    cmd "lua require('smart-splits').resize_up()",    {desc = "Resize Pane/Window Up", silent = true}},
            {"<Down>",  cmd "lua require('smart-splits').resize_down()",  {desc = "Resize Pane/Window Down", silent = true}},
            {"h",       cmd "lua require('smart-splits').move_cursor_left()", {desc = "Move Focus Left", exit = true, silent = true}},
            {"j",       cmd "lua require('smart-splits').move_cursor_down()", {desc = "Move Focus Down", exit = true, silent = true}},
            {"k",       cmd "lua require('smart-splits').move_cursor_up()",   {desc = "Move Focus Up", exit = true, silent = true}},
            {"l",       cmd "lua require('smart-splits').move_cursor_right()",{desc = "Move Focus Right", exit = true, silent = true}},
            {"z",       cmd "lua require('maximize').toggle()", {desc = "Maximize current pane", exit = true, silent = true}},
            {"<C-Space>", "<C-\\><C-n>", {desc = "Escape Terminal Mode", exit = true}},
            {"q",       nil, {desc = "quit", exit = true, nowait = true}},
            {"<Esc>",   nil, {desc = "quit", exit = true, nowait = true}}
        }
    })
    hydra({
        name = "LSP Mode",
        mode = {"n"},
        config = {
            color = "pink",
            invoke_on_body = true,
            hint = {
                type = "window",
                position = "bottom-right",
                border = "rounded",
                show_name = true
            },
        },
        hint = [[
        LSP
^
Common Actions
- _h_: Show Hover Doc
- _f_: Format Buffer
- _a_: Code Actions
- _s_: Show Definition
^
Help
- _e_: Show Declerations
- _D_: Show Type Definition
- _j_: Show Sig Help
- _o_: Show Implementation
- _r_: Show References
^
_l_/_q_/_<Esc>_: Exit Hydra
]],
        body = "l",
        heads = {
            {"s", vim.lsp.buf.definition, {desc = "Show Description", silent = true}},
            {"h", vim.lsp.buf.hover, {desc = "Show Hover Doc", silent = true}},
            {"o", vim.lsp.buf.implementation, {desc = "Show Implementations", silent = true}},
            {"j", vim.lsp.buf.signature_help, {desc = "Show Sig Help", silent = true}},
            {"r", vim.lsp.buf.references, {desc = "Show References", silent = true}},
            {"f", function() vim.lsp.buf.format({ async = true }) end, {desc = "Format Buffer", silent = true}},
            {"a", vim.lsp.buf.code_action, {desc = "Show Code Actions", silent = true}},
            {"D", vim.lsp.buf.type_definition, {desc = "Show Type Definition", silent = true}},
            {"e", vim.lsp.buf.decleration, {desc = "Show Declerations", silent = true}},
            {"l",       nil, {desc = "quit", exit = true, nowait = true}},
            {"q",       nil, {desc = "quit", exit = true, nowait = true}},
            {"<Esc>",   nil, {desc = "quit", exit = true, nowait = true}}
        }
    })
    hydra({
        name = "DAP",
        mode = {"n"},
        config = {
            color = "pink",
            invoke_on_body = true,
            hint = {
                type = "window",
                position = "middle-right",
                border = "rounded",
                show_name = true,
            },
        },
        hint = [[
          DAP
^
_d_: Toggle Breakpoint
_D_: Set Conditional Breakpoint
_c_: Continue on Break
_S_: Stop Debugger
^
_j_: Step out of code block
_k_: Step over code block
_l_: Step into code block
^
_r_: Open Live REPL
^
_s_/_q_/_<Esc>_: Exit Hydra
]],
        body = "s",
        heads = {
            {"d", cmd "lua require('dap').toggle_breakpoint()", {desc = "Set Breakpoint", silent = true}},
            {"D", cmd "lua require('dap').set_breakpoint(vim.fn.input('Condition: '))", {desc = "Set conditional Breakpoint", silent = true}},
            {"c", cmd "lua require('dap').continue()", {desc = "Continue on break", silent = true}},
            {"j", cmd "lua require('dap').step_out()", {desc = "Step out of code block", silent = true}},
            {"k", cmd "lua require('dap').step_over()", {desc = "Step over code block", silent = true}},
            {"l", cmd "lua require('dap').step_into()", {desc = "Step into code block", silent = true}},
            {"r", cmd "lua require('dap').repl.open()", {desc = "Open Live REPL", silent = true}},
            {"S", cmd "lua require('dap').terminate({},{terminateDebuggee = true}, function() require('dap').close() end)", {desc = "Stop Debugger", exit = true}},
            {"s",       nil, {desc = "quit", exit = true, nowait = true}},
            {"q",       nil, {desc = "quit", exit = true, nowait = true}},
            {"<Esc>",   nil, {desc = "quit", exit = true, nowait = true}}
        }
    })
end)

vim.keymap.set('',  '<Esc>', "<ESC>:noh<CR>:lua import('notify', function(_) _.dismiss() end)<CR>", {silent = true})
vim.keymap.set('n', '<C-t>', ':CFloatTerm<CR>', {silent = true})
vim.keymap.set('t', '<C-t>', '<C-\\><C-n>:CFloatTerm<CR>', {silent = true})
vim.keymap.set('n', '<C-p>', ':CSplitTerm vertical<CR>', {silent = true})
vim.keymap.set('t', '<C-p>', '<C-\\><C-n>:CSplitTerm vertical<CR>', {silent = true})
vim.keymap.set('n', '<C-o>', ':CSplitTerm horizontal<CR>', {silent = true})
vim.keymap.set('t', '<C-o>', '<C-\\><C-n>:CSplitTerm horizontal<CR>', {silent = true})
vim.keymap.set('n', '<C-_>', ':lua require("Comment.api").toggle.linewise()<CR>', {silent = true})
vim.keymap.set('i', '<C-_>', '<ESC>:lua require("Comment.api").toggle.linewise()<CR>i', {silent = true})
vim.keymap.set('x', '<C-_>', '<ESC>:lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>', {silent = true})
vim.keymap.set('n', '<C-s>', ':w<CR>:lua vim.notify(string.format("Saved %s", vim.fn.expand("%:t")), "info")<CR>', {silent=true})
vim.keymap.set('i', '<C-s>', '<esc>:w<CR>:lua vim.notify(string.format("Saved %s", vim.fn.expand("%:t"))), "info")<CR>', {silent=true})
vim.keymap.set('n', '<C-h>', ":lua require('smart-splits').move_cursor_left()<CR>",{silent = true})
vim.keymap.set('n', '<C-j>', ":lua require('smart-splits').move_cursor_down()<CR>", {silent = true})
vim.keymap.set('n', '<C-k>', ":lua require('smart-splits').move_cursor_up()<CR>", {silent = true})
vim.keymap.set('n', "<C-l>", ":lua require('smart-splits').move_cursor_right()<CR>", {silent = true})
vim.keymap.set('t', '<C-h>', "<C-\\><C-n>:lua require('smart-splits').move_cursor_left()<CR>",{silent = true})
vim.keymap.set('t', '<C-j>', "<C-\\><C-n>:lua require('smart-splits').move_cursor_down()<CR>", {silent = true})
vim.keymap.set('t', '<C-k>', "<C-\\><C-n>:lua require('smart-splits').move_cursor_up()<CR>", {silent = true})
vim.keymap.set('t', "<C-l>", "<C-\\><C-n>:lua require('smart-splits').move_cursor_right()<CR>", {silent = true})
vim.keymap.set("n", "<A-h>", "<Plug>(cokeline-focus-prev)", {silent = true})
vim.keymap.set("n", "<A-l>", "<Plug>(cokeline-focus-next)", {silent = true})
vim.keymap.set("n", '/',     ':lua require("searchbox").incsearch({modifier = "disabled"})<CR>', {silent = true})
vim.keymap.set("n", 'r',     ':lua require("searchbox").replace({confirm = "menu"})<CR>', {silent = true})
