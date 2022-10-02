-- Keymappings
vim.keymap.set('n', '<Space>',   '<Nop>', {silent = true})
vim.g.mapleader = ' '

-- Really not fond of this
vim.keymap.set('', '<Esc>',     ':noh<CR><Esc>', {silent = true})
vim.keymap.set('n', 'AA',       'ggVG', {silent = true})
vim.keymap.set('v', 'AA',       'ggV', {silent = true})
vim.keymap.set('n', '<A-Down>', 'ddjP', {silent = true})
vim.keymap.set('n', '<A-Up>',   'ddkP', {silent = true})
vim.keymap.set('n', '<C-x>',    'dd', {silent = true})
vim.keymap.set('n', '<C-X>',    'ddO', {silent = true})
vim.keymap.set('n', '<C-s>',    ':w<CR> :echo "Saved File"<CR>h')
vim.keymap.set('i', '<C-s>',    '<esc>:w<CR> :echo "Saved File"<CR>')
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
