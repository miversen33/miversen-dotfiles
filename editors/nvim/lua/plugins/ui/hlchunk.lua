local exclude_filetypes = {}
for _, ft in ipairs(vim.g._config.excluded_filetypes) do
    exclude_filetypes[ft] = true
end

local hlchunk_opts = {
    chunk = {
        enable = true,
        exclude_filetypes = exclude_filetypes
    },
    indent = {
        enable = true,
        exclude_filetypes = exclude_filetypes
    },
    line_num = {
        enable = true,
        exclude_filetypes = exclude_filetypes
    },
    blank = {
        enable = true,
        exclude_filetypes = exclude_filetypes
    }
}

---@module "lazy"
---@type LazySpec
return {
    "shellRaining/hlchunk.nvim",
    event = {"BufReadPre", "BufNewFile"},
    opts = hlchunk_opts
}
