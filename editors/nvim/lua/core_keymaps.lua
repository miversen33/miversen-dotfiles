local silent_noremap = {noremap = true, silent = true}
local noremap = {noremap=true}

local function map(kind, lhs, rhs, opts)
    vim.api.nvim_set_keymap(kind, lhs, rhs, opts)
end

-- Keymappings
map('n', '<Space>',   '<Nop>', silent_noremap)
vim.g.mapleader = ' '

-- Really not fond of this
map('', '<Esc>',     ':noh<CR><Esc>', silent_noremap)
map('n', 'AA',       'ggVG', silent_noremap)
map('v', 'AA',       'ggV', silent_noremap)
map('n', '<A-Down>', 'ddjP', silent_noremap)
map('n', '<A-Up>',   'ddkP', silent_noremap)
map('n', '<C-x>',    'dd', silent_noremap)
map('n', '<C-X>',    'ddO', silent_noremap)
map('n', '<C-s>',    ':w<CR> :echo "Saved File"<CR>h', noremap)
map('i', '<C-s>',    '<esc>:w<CR> :echo "Saved File"<CR>', noremap)
map('i', '<S-Tab>',  '<esc>:<<CR>i', silent_noremap)
map('n', '<S-Tab>',  ':<<CR>', silent_noremap)
map('n', '<Up>',     'gk', silent_noremap)
map('n', '<Down>',   'gj', silent_noremap)
map('v', '<Up>',     'gk', silent_noremap)
map('v', '<Down>',   'gj', silent_noremap)
map('v', '<Tab>',    ':><CR>', silent_noremap)
map('v', '<S-Tab>',  ':<<CR>', silent_noremap)
map('n', '<C-Del>',  'dw', silent_noremap)
map('i', '<C-Del>',  '<esc>ldwi', silent_noremap)
