vim.g.neo_tree_remove_legacy_commands = 1
vim.g.__miversen_config = {}
-- Setting Basic Vim Settings
local function vim_settings()
    vim.g.__miversen_theme = "default"
    -- Local variable used to dictate the theme of neovim
    local undo_dir = vim.fn.stdpath('cache') .. "/undo/"
    -- Creates the directory we are going to use for undo tracking
    vim.fn.mkdir(undo_dir, 'p')
    -- Use the directory we created earlier to store our undo delta
    vim.opt.undodir = undo_dir
    -- Tells vim to keep track of changes made in a delta file so I can undo
    -- file changes even after closing my neovim instance and reopening it
    vim.opt.undofile = true
    -- How many changes do we keep track of?
    vim.opt.undolevels = 1000
    -- Fixes wezterm artifacts in muxer :(
    vim.opt.termsync = false
    -- Don't move my shit around when you are opening splits
    vim.opt.splitkeep = 'screen'
    -- Gets rid of the icky `~` filling the number column at the end of the file
    vim.opt.fillchars:append(',eob: ')
    -- Ensure there is at least 3 lines between the cursor and the top/bottom of the buffer if possible
    vim.opt.scrolloff = 3
    -- Limit how many lines of scrollback history `:h term` keeps
    vim.opt.scrollback = 5000
    -- Ya I sometimes use the mouse. Fucking sue me
    vim.opt.mouse = 'a'
    vim.opt.mousemodel = 'extend'
    -- Enables tracking of mouse movement. Or more specifically, mouse hover
    vim.opt.mousemoveevent = true
    -- Sets what the cursor will look like in each mode. I did not make this mess, I found it on /r/neovim somewhere
    -- It basically ensures I have a "blinking line" when in insert mode and a block all other times
    vim.opt.guicursor =
        'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175'
    vim.opt.whichwrap = '<,>,[,]'
    vim.opt.encoding = 'UTF-8'
    vim.log.level = "warn"
    -- Enables line numbers
    vim.opt.number = true
    -- Enables syntax highlighting
    vim.opt.syntax = 'enable'
    -- Enable auto read from disk. If a file changes, we should enable this
    vim.opt.autoread = true -- though maybe it makes sense for this to be toggleable?
    -- Tells the host term to enable 24bit color instead of 8
    vim.opt.termguicolors = true
    -- A tab is 4 spaces. If you think otherwise, you are wrong
    vim.opt.tabstop = 4
    -- I use lualine (and a tabbar and my cursorline) to tell me what mode I am in. I 
    -- don't need vim to also tell me
    vim.opt.showmode = false
    -- If tabs are 4 spaces, indents should be 1 tab. Vim defaulting to 8 is just fucking silly
    vim.opt.shiftwidth = 4
    -- Tab is 4 spaces.
    vim.opt.softtabstop = 4
    -- How wide is my number column? I have it set to 2, though I might bump it up to 3 so include more info there. Not sure yet
    vim.opt.numberwidth = 3
    -- Enable line wrapping
    vim.opt.wrap = true
    -- force all yanks into clipboard
    vim.opt.clipboard:append('unnamedplus')
    vim.opt.background = 'dark'
    -- Keep my last search highlighted until I disable it. I have <esc><esc> mapped to :nohl (among other things)
    vim.opt.hlsearch = true
    -- ignore case when searching/replacing
    vim.opt.ignorecase = true
    -- Show my substitutions in the buffer as I type them. Super great for visually seeing what I am about to do
    vim.opt.incsearch = true
    -- Allows hidding abandoned buffers. Not terribly sure this is useful but 🤷
    vim.opt.hidden = true
    -- -- fold by indent. Since indents are now consistent (see above), this allows for consistent folding
    -- vim.opt.foldmethod     = "indent"
    -- fold using treesitter instead
    vim.opt.foldmethod = 'expr'
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    -- how many folds are we willing to do within a fold before we just stop folding
    vim.opt.foldlevel = 99
    -- Enables listchars
    vim.opt.list = true
    -- vim.opt.spell         = true
    -- Hide commandline when not in use
    vim.opt.cmdheight = 0

    vim.opt.listchars = {
        -- Replace tab whitespace with -->
        tab = '-->',
        -- I don't care about spaces so spaces are just plain old whitespace
        multispace = ' ',
        -- nbsp=' ',
        -- If a line ends with a space, I probably do care about that, show this instead of whitespace
        trail = '',
        -- If the line goes off the screen (for some reason), show this as the last character of the line so I know the
        -- line continues to the right
        extends = '⟩',
        -- Literally the same but left
        precedes = '⟨'
    }
    -- Tells me if there is the line is wrapped
    vim.g.showbreak = '↪'
    -- Show cursorline
    vim.opt.cursorline = true
    -- Put my horizontal splits to the right instead of the left
    vim.opt.splitright = true
    -- Put my vertical splits under me instead of above me
    vim.opt.splitbelow = true
    -- Tab is 4 spaces. Make it 4 spaces
    vim.opt.expandtab = true
    -- Be smart about tabs when opening an existing file. Tabs are 4 spaces for me,
    -- but they may be 8 in another file, or actual \t. Handle that all gracefully
    vim.opt.smarttab = true
    -- Honestly I can probably get rid of this since I don't use omnifunc
    vim.opt.completeopt = 'longest,preview,menuone,noselect'
    -- Syntax highlighting in strings for augroups, lua, perl, python, javascript. Useful if you are doing stuff like
    -- generating SQL/HTML/XML in strings
    vim.g.vimsyn_embed = 'alpPrj'
    -- How long between "do-nothing" time do we write swap to disk
    vim.opt.updatetime = 2000
    -- Session options for resuming neovim where I was before. Use whatever the session plugin you are using recommends
    -- NOTE: You don't need to use a plugin for session management, I just chose to because I am lazy
    vim.opt.sessionoptions =
        "blank,buffers,curdir,folds,tabpages,winsize,winpos,terminal,localoptions,options,resize"
    for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
        vim.api.nvim_set_hl(0, group, {})
    end
    local _print = _G.print
    local clean_string = function(...)
        local args = {n = select("#", ...), ...}
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
        vim.notify(table.concat(formatted_args, ' '), vim.log.levels.INFO)
    end
    _G.print = function(...) _print(clean_string(...)) end
    vim.g.__miversen_set_theme = function(new_theme, lualine_theme)
        lualine_theme = lualine_theme or new_theme
        if vim.g.__miversen_theme and vim.g.__miversen_theme ~= 'default' and
            vim.g.__miversen_theme ~= new_theme then
            print('Replacing previously selected theme "',
                  vim.g.__miversen_theme, '" with', new_theme)
        end
        vim.g.__miversen_theme = new_theme
        vim.g.__miversen_lualine_theme = lualine_theme
    end
    local old_g = {}
    _G.set_theme = function(theme_name, lualine_theme)
        old_g = vim.api.nvim_eval('g:')
        lualine_theme = lualine_theme or theme_name
        vim.g.__miversen_theme = theme_name

        vim.cmd.colorscheme(vim.g.__miversen_theme)
        if type(lualine_theme) == 'function' then
            vim.g.__miversen_lualine_theme = lualine_theme()
        else
            vim.g.__miversen_lualine_theme = lualine_theme
        end
    end
    local uv = vim.uv or vim.loop
    vim.g.__miversen_background_color = "#1e1e1e"
    _G.os_sep = uv.os_uname().sysname:lower():match('windows') and '\\' or '/' -- \ for windows, mac and linux both use \
    _G.__miversen_border_color = "#806d9c"
    _G.__miversen_augroup = "miversen_config_augroup"
    vim.api.nvim_create_augroup(_G.__miversen_augroup, {clear = true})
end

local function setup_basic_keycommands()
    local function save()
        local filename = vim.fn.expand("%:t")
        local write_success, error_message = pcall(vim.api.nvim_command, ':w')
        if write_success then
            vim.notify(string.format("Saving %s", filename), vim.log.levels.INFO)
        else
            vim.notify(string.format("Error while saving %s\n\t%s", filename,
                                     error_message), vim.log.levels.ERROR)
        end
        local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
        vim.api.nvim_feedkeys(esc, 'm', false)
    end

    local function do_exit()
        vim.cmd('noh')
        local success, notify, hover, specs, cmp = nil, nil, nil, nil, nil
        success, notify = pcall(require, "notify")
        if success then notify.dismiss() end
        success, hover = pcall(require, "pretty_hover")
        if success then hover.close() end
        success, specs = pcall(require, "specs")
        if success then specs.show_specs() end
        success, _ = pcall(require, "fidget")
        if success then pcall(vim.cmd, 'Fidget clear') end
        success, cmp = pcall(require, 'cmp')
        if success then cmp.close() end
        local key = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
        vim.api.nvim_feedkeys(key, 'n', false)
    end

    local jump_to_next_word_pattern =
        [[\v['"({[< ]@<=(\w)|^(\w)|([]'"\>)}]\.)@<=(\w)|(['"])@<=([][(){}.,;])(['"])]]

    -- Keymappings
    vim.keymap.set('n', '<Space>', '<Nop>', {silent = true})
    vim.g.mapleader = ' '
    vim.g.maplocalleader = ','

    vim.keymap.set('n', 'AA', 'ggVG', {silent = true})
    vim.keymap.set('v', 'AA', 'ggV', {silent = true})
    vim.keymap.set('n', '<A-Down>', 'ddjP', {silent = true})
    vim.keymap.set('n', '<A-Up>', 'ddkP', {silent = true})
    vim.keymap.set('n', '<C-x>', 'dd', {silent = true})
    vim.keymap.set('n', '<C-X>', 'ddO', {silent = true})
    vim.keymap.set('i', '<S-Tab>', '<esc>:<<CR>i', {silent = true})
    vim.keymap.set('n', '<S-Tab>', ':<<CR>', {silent = true})
    vim.keymap.set('n', '<Up>', 'gk', {silent = true})
    vim.keymap.set('n', '<Down>', 'gj', {silent = true})
    vim.keymap.set('v', '<Up>', 'gk', {silent = true})
    vim.keymap.set('v', '<Down>', 'gj', {silent = true})
    vim.keymap.set('v', '<Tab>', ':><CR>', {silent = true})
    vim.keymap.set('v', '<S-Tab>', ':<<CR>', {silent = true})
    vim.keymap.set('n', '<C-Del>', 'dw', {silent = true})
    vim.keymap.set('i', '<C-Del>', '<esc>ldwi', {silent = true})
    vim.keymap.set({"n", "i", "v"}, "<C-s>", save, {silent = true})
    vim.keymap.set('n', 'zz', 'zc', {silent = true}) -- Fold
    vim.keymap.set('n', 'Zz', 'zo', {silent = true}) -- Unfold
    vim.keymap.set({'n', 'i', 'v', 's', 'c', 'x'}, '<Esc>', do_exit,
                   {silent = true})
    vim.keymap.set({'n', 'v'}, 'e',
                   function() vim.fn.search(jump_to_next_word_pattern) end)
    vim.keymap.set({'n', 'v'}, 'E', function()
        -- (word) backwards
        vim.fn.search(jump_to_next_word_pattern, 'b')
    end)
end

local function setup_advanced_keycommands()
    local success, hydra = pcall(require, "hydra")
    if not success then
        print("Unable to locate hydra!")
        return
    end

    vim.keymap.set('n', '<C-t>', ':CFloatTerm<CR>', {silent = true})
    vim.keymap.set({'n', 'v'}, '<C-f>', function()
        require("telescope").extensions.live_grep_args.live_grep_args()
    end, {silent = true})
    vim.keymap.set({"n", "v", "i", "t"}, "<C-S-o>", function()
        require("telescope.command").load_command("builtin",
                                                  "layout_config={width=0.95,height=0.9}")
    end, {silent = true})
    vim.keymap.set('t', '<C-t>', '<C-\\><C-n>:CFloatTerm<CR>', {silent = true})
    vim.keymap.set('n', '<C-p>', ':CSplitTerm vertical<CR>', {silent = true})
    vim.keymap.set('t', '<C-p>', '<C-\\><C-n>:CSplitTerm vertical<CR>',
                   {silent = true})
    vim.keymap.set('n', '<C-u>', ':CSplitTerm horizontal<CR>', {silent = true})
    vim.keymap.set('t', '<C-u>', '<C-\\><C-n>:CSplitTerm horizontal<CR>',
                   {silent = true})
    vim.keymap.set('n', '<C-_>',
                   ':lua require("Comment.api").toggle.linewise()<CR>',
                   {silent = true})
    vim.keymap.set('i', '<C-_>',
                   '<ESC>:lua require("Comment.api").toggle.linewise()<CR>i',
                   {silent = true})
    vim.keymap.set('x', '<C-_>',
                   '<ESC>:lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>',
                   {silent = true})
    vim.keymap.set('n', '<C-h>',
                   ":lua require('smart-splits').move_cursor_left()<CR>",
                   {silent = true})
    vim.keymap.set('n', '<C-j>',
                   ":lua require('smart-splits').move_cursor_down()<CR>",
                   {silent = true})
    vim.keymap.set('n', '<C-k>',
                   ":lua require('smart-splits').move_cursor_up()<CR>",
                   {silent = true})
    vim.keymap.set('n', "<C-l>",
                   ":lua require('smart-splits').move_cursor_right()<CR>",
                   {silent = true})
    vim.keymap.set('t', '<C-h>',
                   "<C-\\><C-n>:lua require('smart-splits').move_cursor_left()<CR><ESC>",
                   {silent = true})
    vim.keymap.set('t', '<C-j>',
                   "<C-\\><C-n>:lua require('smart-splits').move_cursor_down()<CR><ESC>",
                   {silent = true})
    vim.keymap.set('t', '<C-k>',
                   "<C-\\><C-n>:lua require('smart-splits').move_cursor_up()<CR><ESC>",
                   {silent = true})
    vim.keymap.set('t', "<C-l>",
                   "<C-\\><C-n>:lua require('smart-splits').move_cursor_right()<CR><ESC>",
                   {silent = true})
    -- vim.keymap.set({'n', 'x'}, '<C-d>', '<Cmd>MultipleCursorsAddJumpNextMatch<CR>', {silent = true})
    -- vim.keymap.set({'n', 'x', 'i'}, '<C-Up>', '<Cmd>MultipleCursorsAddUp<CR>', {silent = true})
    -- vim.keymap.set({'n', 'x', 'i'}, '<C-Down>', '<Cmd>MultipleCursorsAddDown<CR>', {silent = true})

    vim.keymap.set('n', '<C-q>', function()
        local success, cokeline = pcall(require, 'cokeline.tabs')
        if not success then
            local close_success = pcall(vim.cmd, 'tabclose')
            if not close_success then
                vim.notify('Cannot close last tab!', vim.log.levels.ERROR)
                return
            end
            return
        end
        for _, tabpage in ipairs(cokeline.get_tabs()) do
            if tabpage.is_active and #tabpage.windows > 0 then
                vim.ui.input({
                    prompt = 'This tabpage has open windows still, are you sure you want to close it?'
                }, function(answer)
                    if not answer or not answer:lower():match('^y[es]?') then
                        vim.notify('Canceling tab closure', vim.log.levels.WARN)
                        return
                    end
                    tabpage:close()
                end)
            end
        end
    end, {silent = true})
    vim.keymap.set('n', '<C-n>', ':tabnew<CR>', {silent = true})
    vim.keymap.set("n", "<S-h>", ":tabp<CR>", {silent = true})
    vim.keymap.set("n", "<S-l>", ":tabn<CR>", {silent = true})
    vim.keymap.set("n", '<A-Down>', ':MoveLine(1)<CR>', {silent = true})
    vim.keymap.set("n", '<A-Up>', ':MoveLine(-1)<CR>', {silent = true})
    vim.keymap.set("i", '<A-Up>', '<ESC>:MoveLine(-1)<CR>i', {silent = true})
    vim.keymap.set("i", '<A-Down>', '<ESC>:MoveLine(1)<CR>i', {silent = true})
    vim.keymap.set("v", '<A-Down>', ':MoveBlock(1)<CR>', {silent = true})
    vim.keymap.set("v", '<A-Up>', ':MoveBlock(-1)<CR>', {silent = true})
    vim.keymap.set("n", "<C-Enter>", ":Glance definitions<CR>", {silent = true})
    vim.keymap.set("t", "<S-space>", "<space>", {silent = true})
    vim.keymap.set("t", "<S-BS>", "<BS>", {silent = true})
    vim.api.nvim_set_keymap('n', 'n',
                            [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
                            {noremap = true, silent = true})
    vim.api.nvim_set_keymap('n', 'N',
                            [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
                            {noremap = true, silent = true})
    vim.api.nvim_set_keymap('n', '*',
                            [[*<Cmd>lua require('hlslens').start()<CR>]],
                            {noremap = true, silent = true})
    vim.api.nvim_set_keymap('n', '#',
                            [[#<Cmd>lua require('hlslens').start()<CR>]],
                            {noremap = true, silent = true})
    vim.api.nvim_set_keymap('n', 'g*',
                            [[g*<Cmd>lua require('hlslens').start()<CR>]],
                            {noremap = true, silent = true})
    vim.api.nvim_set_keymap('n', 'g#',
                            [[g#<Cmd>lua require('hlslens').start()<CR>]],
                            {noremap = true, silent = true})
    -- vim.keymap.set("n", '/',     ':lua require("searchbox").incsearch({modifier = "disabled"})<CR>', {silent = true})
    -- vim.keymap.set("n", 'r',     ':lua require("searchbox").replace({confirm = "menu"})<CR>', {silent = true})
    vim.api.nvim_create_user_command('Ls', ':Telescope buffers', {})
end

local function setup_config_watcher()
    -- TODO: Mike, setup a series of watcher for the entire configuration directory for neovim
end

local function check_if_debug()
    vim.g.__miversen_debug_config = vim.loop.os_getenv('DEBUG_NEOVIM_CONFIG')
    if vim.g.__miversen_debug_config then
        vim.notify("Running Neovim in Configuration Debug Mode!", "warn")
    end
end

local function setup_plugins()
    _G.__miversen_config_excluded_filetypes_array = {
        "lsp-installer", "grug-far", "lspinfo", "Outline", "lazy", "help",
        "packer", "netrw", "qf", "dbui", "Trouble", "fugitive", "floaterm",
        "spectre_panel", "spectre_panel_write", "checkhealth", "man",
        "dap-repl", "toggleterm", "neo-tree", "ImportManager", "aerial",
        "TelescopePrompt", "TelescopeResults", "NetmanLogs", "neo-tree-popup", "",
        "dapui_scopes", "dapui_breakpoints", "dapui_stacks", "dapui_watches", "dap-repl", 
        "dapui_console"
    }
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    -- local lazypath = "/tmp/lazy/lazy.nvim"
    local lazyurl = "https://github.com/folke/lazy.nvim.git"
    local lazybranch = "stable"
    if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
            "git", "clone", "--filter=blob:none", lazyurl,
            string.format("--branch=%s", lazybranch), lazypath
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
            patterns = {"miversen33", "nvim-island"},
            fallback = true
        },
        change_detection = {enabled = false, notify = true},
        ui = {border = 'rounded'},
        spec = {
            {import = "plugins.ui.theme"},
            {import = "plugins.ui"},
            {import = "plugins.ui.core"},
            {import = "plugins.ide"},
            {import = "plugins.ide.core"},
            {import = "plugins.ide.languages.hex" },
            {import = "plugins.ide.languages.glsl"},
            {import = "plugins.ide.languages.haskell"},
            {import = "plugins.ide.languages.java"},
            {import = "plugins.ide.languages.neovim"},
            {import = "plugins.ide.languages.python"},
            {import = "plugins.ide.languages.rust"},
            {import = "plugins.ide.languages.svelte"},
            {import = "plugins.ide.languages.markdown"},
            -- { import = "plugins.ide.sql" },
        }
    }
    lazy.setup(lazy_opts)
    -- Setting up some basic highlight groups
    -- vim.api.nvim_set_hl(0, "ColorColumn", {fg = "#97E004"})
    _G.set_theme(vim.g.__miversen_theme)
    vim.api.nvim_set_hl(0, "PmenuSel", {bg = "#004b72", fg = "NONE"})
    vim.api.nvim_set_hl(0, "Pmenu", {fg = "#C5CDD9", bg = "NONE"})
    vim.api.nvim_set_hl(0, "FloatBorder", {fg = _G.__miversen_border_color})
    vim.api.nvim_set_hl(0, "TelescopePromptBorder", {fg = _G.__miversen_border_color})
    vim.api.nvim_set_hl(0, "TelescopeResultsBorder", {fg = _G.__miversen_border_color})
    vim.api.nvim_set_hl(0, "TelescopePreviewBorder", {fg = _G.__miversen_border_color})
    vim.api.nvim_set_hl(0, "TelescopeBorder", {fg = _G.__miversen_border_color})

    vim.api.nvim_set_hl(0, "NormalFloat", {fg = "NONE", bg = "NONE"})
end

local cleanup = function()
    vim.g.__miversen_set_theme = nil
end

vim_settings()
setup_basic_keycommands()
setup_config_watcher()
check_if_debug()
if not vim.g.__miversen_debug_config then
    setup_plugins()
    setup_advanced_keycommands()
end
require("scripts")
cleanup()
