local function lsplines_config()
    require("lsp_lines").setup()
    vim.diagnostic.config({virtual_text = false})
end

local lsplines = {
    url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = lsplines_config
}

return lsplines
