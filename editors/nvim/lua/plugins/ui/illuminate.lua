local illuminate_opts = {
    providers = {
        -- Omitting treesitter for now because I don't trust it with big files...
        "lsp", "regex", -- "treesitter"
    }
}

local illuminate = {
    "RRethy/vim-illuminate",
    config = function()
        require("illuminate").configure(illuminate_opts)
        vim.api.nvim_set_hl(0, "IlluminatedWordText", { italic = true, underline = true, bold = true })
        vim.api.nvim_set_hl(0, "IlluminatedWordRead", { italic = true, underline = true, bold = true })
        vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { italic = true, underline = true, bold = true})
    end
}

return illuminate
