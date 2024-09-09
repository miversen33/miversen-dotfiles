local vscode_opts = {
    -- transparent = true,
    italic_comments = true,
    underline_links = true,
    group_overrides = {
        WinBar = { bg = nil, italic = true }
    },
}

-- Uncomment this if you want to set the theme to vscode
-- vim.g.__miversen_set_theme('vscode')

---@module "lazy"
---@type LazySpec
return {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    opts = vscode_opts
}
