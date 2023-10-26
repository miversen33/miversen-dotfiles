local hlchunk_opts = {
    chunk = {
        enable = true,
        notify = false,
        exclude_filetypes = _G.__miversen_config_excluded_filetypes_array
    },
    indent = {
        enable = true,
        notify = false,
        exclude_filetypes = _G.__miversen_config_excluded_filetypes_array
    },
    line_num = {
        enable = true,
        notify = false,
        exclude_filetypes = _G.__miversen_config_excluded_filetypes_array
    },
    blank = {
        enable = true,
        notify = false,
        exclude_filetypes = _G.__miversen_config_excluded_filetypes_array
    }
}

local hlchunk = {
    "shellRaining/hlchunk.nvim",
    event = "UIEnter",
    config = true,
    opts = hlchunk_opts
}

return hlchunk
