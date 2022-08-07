local silent_noremap = {noremap = true, silent = true}
local noremap = {noremap=true}

local function copy(lines, _)
  require('osc52').copy(table.concat(lines, '\n'))
end

local function paste()
  return {
    vim.fn.split(vim.fn.getreg(''), '\n'),
    vim.fn.getregtype('')
  }
end

vim.g.clipboard = {
  name = "osc52",
  copy = {
    ["+"] = copy,
    ["*"] = copy
  },
  paste = {
    ["+"] = paste,
    ["*"] = paste
  }
}

local function map(kind, lhs, rhs, opts)
    vim.api.nvim_set_keymap(kind, lhs, rhs, opts)
end

map('n', 'tls'           , ':lua require("telescope.builtin").buffers()<CR>', silent_noremap)
map('n', '?'             , ':lua require("telescope.builtin").builtin()<CR>', silent_noremap)
map('n', 'th?'           , ':lua require("telescope.builtin").help_tags()<CR>', silent_noremap)
map('n', 'tc?'           , ':lua require("telescope.builtin").commands()<CR>', silent_noremap)
map('n', 'tk?'           , ':lua require("telescope.builtin").keymaps()<CR>', silent_noremap)
map('n', 'ts'            , ':lua require("telescope.builtin").current_buffer_fuzzy_find({skip_empty_lines=true})<CR>', silent_noremap)
map('n', 'tS'            , ':lua require("telescope.builtin").live_grep({use_regex=true})<CR>', silent_noremap)
map('n', 'tt'            , ':lua require("telescope.builtin").treesitter()<CR>', silent_noremap)
map('n', 'tm'            , ':lua require("telescope.builtin").man_pages()<CR>', silent_noremap)
map('n', 'tf'            , ':lua require("telescope").extensions.file_browser.file_browser()<CR>', silent_noremap)
map('n', '<leader>t'     , ':TroubleToggle<CR>', silent_noremap)
map('n', '<C-t>'         , ':CFloatTerm<CR>', silent_noremap)
map('t', '<C-t>'         , '<C-\\><C-n>:CFloatTerm<CR>', silent_noremap)
map('n', '<C-y>'         , ':CReplTerm<CR>', silent_noremap)
map('t', '<C-y>'         , '<C-\\><C-n>:CReplTerm<CR>', silent_noremap)
map('n', '<C-p>'         , ':CSplitTerm vertical<CR>', silent_noremap)
map('t', '<C-p>'         , '<C-\\><C-n>:CSplitTerm vertical<CR>', silent_noremap)
map('n', '<C-o>'         , ':CSplitTerm horizontal<CR>', silent_noremap)
map('t', '<C-o>'         , '<C-\\><C-n>:CSplitTerm horizontal<CR>', silent_noremap)
map('t', '<C-h>'         , '<C-\\><C-n>:silent! lua require("smart-splits").move_cursor_left()<CR>', silent_noremap)
map('t', '<C-j>'         , '<C-\\><C-n>:silent! lua require("smart-splits").move_cursor_up()<CR>', silent_noremap)
map('t', '<C-l>'         , '<C-\\><C-n>:silent! lua require("smart-splits").move_cursor_right()<CR>', silent_noremap)
map('t', '<C-k>'         , '<C-\\><C-n>:silent! lua require("smart-splits").move_cursor_down()<CR>', silent_noremap)
map('n', 'sr'            , ':lua vim.lsp.buf.rename()<CR>', silent_noremap)
map('n', 'se'            , ':lua vim.lsp.buf.definition()<CR>', silent_noremap)
map('n', 'sf'            , ':echo "Formatting Buffer"<CR> :lua vim.lsp.buf.formatting()<CR>', silent_noremap)
map('n', '<C-_>'         , ':lua require("Comment.api").toggle_current_linewise()<CR>', silent_noremap)
map('i', '<C-_>'         , '<ESC>:lua require("Comment.api").toggle_current_linewise()<CR>i', silent_noremap)
map('n', '<C-_>'         , '<ESC>:lua require("Comment.api").toggle_current_linewise()<CR>', silent_noremap)
map('x', '<C-_>'         , '<ESC>:lua require("Comment.api").toggle_linewise_op(vim.fn.visualmode())<CR>', silent_noremap)
map('n', 'n'             , ':lua require("illuminate").next_reference({wrap=true})<CR>', silent_noremap)
map('n', '<S-n>'         , ':lua require("illuminate").next_reference({reverse=true,wrap=true})<CR>', silent_noremap)
map('n', '<A-f>'         , ':Telescope find_files<CR>', silent_noremap)
map('n', '<Enter>'       , ':AerialToggle! right<CR>', silent_noremap)
map('n', '<leader>r'     , ':lua require("spectre").open_file_search()<CR>', silent_noremap)
map('n', '<leader>b'     , ':lua require("dap").toggle_breakpoint()<CR>', silent_noremap)
map('n', '<leader>B'     , ':lua require("dap").set_breakpoint(vim.fn.input("Condition: "))<CR>', silent_noremap)
map('n', '<F5>'          , ':lua require("dap").continue()<CR>', silent_noremap)
map('n', '<F6>'          , ':lua require("dap").run_last()<CR>', silent_noremap)
map('n', '<leader>up'    , ':lua require("dap").step_out()<CR>', silent_noremap)
map('n', '<leader>down'  , ':lua require("dap").step_into()<CR>', silent_noremap)
map('n', '<leader>right' , ':lua require("dap").step_over()<CR>', silent_noremap)
map('n', '<leader>ro'    , ':lua require("dap").repl.open()<CR>', silent_noremap)
map('n', '<C-h>'         , ':lua require("smart-splits").move_cursor_left()<CR>', silent_noremap)
map('n', '<C-j>'         , ':lua require("smart-splits").move_cursor_up()<CR>', silent_noremap)
map('n', '<C-l>'         , ':lua require("smart-splits").move_cursor_right()<CR>', silent_noremap)
map('n', '<C-k>'         , ':lua require("smart-splits").move_cursor_down()<CR>', silent_noremap)
map('n', '<A-left>'      , ':lua require("smart-splits").resize_left()<CR>', silent_noremap)
map('n', '<A-right>'     , ':lua require("smart-splits").resize_right()<CR>', silent_noremap)
map('n', '<A-up>'        , ':lua require("smart-splits").resize_up()<CR>', silent_noremap)
map('n', '<A-down>'      , ':lua require("smart-splits").resize_down()<CR>', silent_noremap)
map('n', '<A-h>'         , '<Plug>(cokeline-focus-prev)', silent_noremap)
map('n', '<A-l>'         , '<Plug>(cokeline-focus-next)', silent_noremap)
map('n', '<A-j>'         , '<Plug>(cokeline-switch-prev)', silent_noremap)
map('n', '<A-k>'         , '<Plug>(cokeline-switch-next)', silent_noremap)
