local exclude_filetypes = {}
for _, ft in ipairs(_G.__miversen_config_excluded_filetypes_array) do
    exclude_filetypes[ft] = true
end

local hlchunk_opts = {
    chunk = {
        enable = true,
        notify = false,
        exclude_filetypes = exclude_filetypes
    },
    indent = {
        enable = true,
        notify = false,
        exclude_filetypes = exclude_filetypes
    },
    line_num = {
        enable = true,
        notify = false,
        exclude_filetypes = exclude_filetypes
    },
    blank = {
        enable = true,
        notify = false,
        exclude_filetypes = exclude_filetypes
    }
}

local hlchunk = {
    "shellRaining/hlchunk.nvim",
    event = "UIEnter",
    config = true,
    opts = hlchunk_opts
}

return hlchunk
