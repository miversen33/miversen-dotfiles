local silent_noremap = {noremap = true, silent = true}
local noremap = {noremap=true}

local function map(kind, lhs, rhs, opts)
    vim.api.nvim_set_keymap(kind, lhs, rhs, opts)
end

local telescope = require('telescope')

-- Keymappings
map('n', '<Space',   '<Nop>', silent_noremap)
vim.g.mapleader = ' '

map('n', '<A-k>',    ':m .+1<CR>==', silent_noremap)
map('n', '<A-i>',    ':m .-2<CR>==', silent_noremap)
map('n', '<C-u>',    ':tabp<CR>:echo "Tab Left"<CR>' , noremap)
map('n', '<C-o>',    ':tabn<CR>:echo "Tab Right"<CR>', noremap)
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
map('i', '<S-Tab>',  '<esc>:<<<CR>i', silent_noremap)
map('n', '<S-Tab>',  ':<<<CR>', silent_noremap)
map('n', '<C-f>',    '/', noremap)
map('i', '<C-f>',    '<esc>/', noremap)
map('n', '<leader>f',':noh<CR>', silent_noremap)
map('n', '<S-f>',    ':Telescope live_grep<CR>', noremap)
map('n', '<C-z>',    ':Telescope find_files<CR>', silent_noremap)
map('n', '<S-z>',    ':Telescope live_grep<CR>', silent_noremap)
map('n', '<C-T>',    ':TroubleToggle<CR>', silent_noremap)
map('n', '<C-h>',    ':lua vim.lsp.buf.hover()<CR>', silent_noremap)
map('n', '<A-left>', ':vertical resize -5<CR>', silent_noremap)
map('n', '<A-right>',':vertical resize +5<CR>', silent_noremap)
map('n', '<A-down>', ':resize -5<CR>', silent_noremap)
map('n', '<A-up>',   ':resize +5<CR>', silent_noremap)
map('n', '<C-_>',    ':lua require("Comment.api").toggle_current_linewise()<CR>', silent_noremap)
map('i', '<C-_>',    '<ESC>:lua require("Comment.api").toggle_current_linewise()<CR>i', silent_noremap)
map('x', '<C-_>',    '<ESC>:lua require("Comment.api").toggle_linewise_op(vim.fn.visualmode())<CR>', silent_noremap)
map('n', '<C-n>',    ':lua require("illuminate").next_reference{wrap=true}<CR>', silent_noremap)
map('n', '<S-n>',    ':lua require("illuminate").next_reference{reverse=true,wrap=true}<CR>', silent_noremap)
map('n', '<A-f>',    ':echo "Formatting Buffer"<CR> :lua vim.lsp.buf.formatting()<CR>', silent_noremap)
-- map('n', '<Enter>',  ':SymbolsOutline<CR>', silent_noremap)
map('n', '<Enter>',  ':Vista!!<CR>', silent_noremap)
map('n', '<leader>n',':Telescope file_browser<CR>', silent_noremap)
