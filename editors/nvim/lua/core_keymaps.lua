local silent_noremap = {noremap = true, silent = true}
local noremap = {noremap=true}

local function map(kind, lhs, rhs, opts)
    vim.api.nvim_set_keymap(kind, lhs, rhs, opts)
end

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
map('n', '<C-s>',    ':w<CR> :echo "Saved File"<CR>', noremap)
map('i', '<C-s>',    '<esc>:w<CR> :echo "Saved File"<CR>', noremap)
map('i', '<S-Tab>',  '<esc>:<<CR>i', silent_noremap)
map('n', '<S-Tab>',  ':<<CR>', silent_noremap)
-- map('n', '<A-left>', ':vertical resize -5<CR>', silent_noremap)
-- map('n', '<A-right>',':vertical resize +5<CR>', silent_noremap)
-- map('n', '<A-down>', ':resize -5<CR>', silent_noremap)
-- map('n', '<A-up>',   ':resize +5<CR>', silent_noremap)
-- map('n', '<C-j>',    '<C-W><C-h>:echo "Pane Left"<CR>', noremap)
-- map('n', '<C-l>',    '<C-W><C-l>:echo "Pane Right"<CR>', noremap)
-- map('n', '<C-i>',    '<C-W><C-k>:echo "Pane Up"<CR>', noremap)
-- map('n', '<C-k>',    '<C-W><C-j>:echo "Pane Down"<CR>', noremap)
map('v', '<Tab>',    ':><CR>', silent_noremap)
map('v', '<S-Tab>',  ':<<CR>', silent_noremap)
