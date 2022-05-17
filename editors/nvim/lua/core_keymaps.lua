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
map('n', '<C-x>',    'dd', silent_noremap)
map('n', '<C-X>',    'ddO', silent_noremap)
map('n', '<C-s>',    ':w<CR> :echo "Saved File"<CR>', noremap)
map('i', '<C-s>',    '<esc>:w<CR> :echo "Saved File"<CR>', noremap)
map('i', '<S-Tab>',  '<esc>:<<CR>i', silent_noremap)
map('n', '<S-Tab>',  ':<<CR>', silent_noremap)
map('n', '<Up>',     'gk', silent_noremap)
map('n', '<Down>',   'gj', silent_noremap)
map('v', '<Up>',     'gk', silent_noremap)
map('v', '<Down>',   'gj', silent_noremap)
map('i', '<Up>',     '<esc>gki', silent_noremap)
map('i', '<Down>',   '<esc>gji', silent_noremap)
map('v', '<Tab>',    ':><CR>', silent_noremap)
map('v', '<S-Tab>',  ':<<CR>', silent_noremap)
