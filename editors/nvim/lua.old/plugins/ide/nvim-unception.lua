local init = function ()
    -- vim.g.unception_open_buffer_in_new_tab = true
    vim.g.unception_enable_flavor_text = false
    vim.g.unception_block_while_host_edits = true
end

---@module "lazy"
---@type LazySpec
return {
    "samjwill/nvim-unception",
    init = init
}
