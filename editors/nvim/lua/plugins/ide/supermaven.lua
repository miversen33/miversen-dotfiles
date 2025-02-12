---@module "lazy"
---@type LazySpec
return {
    "supermaven-inc/supermaven-nvim",
    opts = {
        keymaps = {
            accept_suggestion = "<C-Enter>",
        },
        ignore_filetypes = _G.__miversen_config_excluded_filetypes_as_table
    },
    enabled = not vim.env.SUPERMAVEN_DISABLED
}
