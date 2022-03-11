local silent_noremap = {noremap = true, silent = true}
local noremap = {noremap=true}

local function map(kind, lhs, rhs, opts)
    vim.api.nvim_set_keymap(kind, lhs, rhs, opts)
end

local telescope = require('telescope')

map('n', '<S-f>',    ':Telescope live_grep<CR>', noremap)
map('n', '<C-z>',    ':Telescope find_files<CR>', silent_noremap)
map('n', '<S-z>',    ':Telescope live_grep<CR>', silent_noremap)
map('n', '<C-T>',    ':TroubleToggle<CR>', silent_noremap)
map('n', '<C-h>',    ':lua vim.lsp.buf.hover()<CR>', silent_noremap)
map('n', '<C-_>',    ':lua require("Comment.api").toggle_current_linewise()<CR>', silent_noremap)
map('i', '<C-_>',    '<ESC>:lua require("Comment.api").toggle_current_linewise()<CR>i', silent_noremap)
map('n', '<C-_>',    '<ESC>:lua require("Comment.api").toggle_current_linewise()<CR>', silent_noremap)
map('x', '<C-_>',    '<ESC>:lua require("Comment.api").toggle_linewise_op(vim.fn.visualmode())<CR>', silent_noremap)
map('n', '<C-n>',    ':lua require("illuminate").next_reference{wrap=true}<CR>', silent_noremap)
map('n', '<S-n>',    ':lua require("illuminate").next_reference{reverse=true,wrap=true}<CR>', silent_noremap)
map('n', '<A-fr>',   ':echo "Formatting Buffer"<CR> :lua vim.lsp.buf.formatting()<CR>', silent_noremap)
map('n', '<A-f>',    ':Telescope find_files<CR>', silent_noremap)
-- map('n', '<Enter>',  ':SymbolsOutline<CR>', silent_noremap)
map('n', '<Enter>',  ':Vista!!<CR>', silent_noremap)
map('n', '<leader>n',':Telescope file_browser<CR>', silent_noremap)
map('n', '<leader>r',':lua require("spectre").open_file_search()<CR>', silent_noremap)
map('n', '<leader>b',':lua require("dap").toggle_breakpoint()<CR>', silent_noremap)
map('n', '<leader>B',':lua require("dap").set_breakpoint(vim.fn.input("Condition: "))<CR>', silent_noremap)
map('n', '<F5>',     ':lua require("dap").continue()<CR>', silent_noremap)
map('n', '<F6>',     ':lua require("dap").run_last()<CR>', silent_noremap)
map('n', '<leader>up',':lua require("dap").step_out()<CR>', silent_noremap)
map('n', '<leader>down', ':lua require("dap").step_into()<CR>', silent_noremap)
map('n', '<leader>right', ':lua require("dap").step_over()<CR>', silent_noremap)
map('n', '<leader>ro', ':lua require("dap").repl.open()<CR>', silent_noremap)