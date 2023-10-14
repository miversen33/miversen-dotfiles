local ccc_config = {
    highlighter = {
        auto_enable = true,
        excludes = _G.__miversen_config_excluded_filetypes_array
    }
}

local ccc = {
    "uga-rosa/ccc.nvim",
    config = ccc_config
}

return ccc
