vim.api.nvim_command([[
    let g:VM_maps = {}
    let g:VM_maps['Find Under'] = '<C-d>'
    let g:VM_maps['Find Subword Under'] = '<C-d>'
]])

local vim_visual_multi = {
    "mg979/vim-visual-multi",
    config = false
}

return vim_visual_multi
