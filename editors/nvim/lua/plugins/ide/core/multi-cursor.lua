-- return {
--   "brenton-leighton/multiple-cursors.nvim",
--   version = "*",  -- Use the latest tagged version
--   opts = {},  -- This causes the plugin setup function to be called
-- }
-- vim.g.VM_custom_noremaps = true
-- dunno why but this does work with vim.g.VM_maps
vim.cmd([[
  let g:VM_maps = {}
  let g:VM_maps['Find Under'] = '<C-d>'
  let g:VM_maps['Find Subword Under'] = '<C-d>'
  let g:VM_maps["Add Cursor Down"] = '<C-Down>'
  let g:VM_maps["Add Cursor Up"] = '<C-Up>'
  let g:VM_silent_exit=1
]])

---@module "lazy"
---@type LazySpec
return {"mg979/vim-visual-multi"}
