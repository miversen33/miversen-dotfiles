local ranger_opts = {
    replace_netrw = true,
    ui = {
        border = "none",
        height = 1,
        width = 1,
        x = 0.5,
        y = 0.5
    }
}

local enabled = vim.fn.executable('ranger')
if enabled then
    vim.g.__miversen_config.has_ranger = true
end

---@module "lazy"
---@type LazySpec
return {
    "kelly-lin/ranger.nvim",
    opts = ranger_opts,
    enabled = enabled
}
