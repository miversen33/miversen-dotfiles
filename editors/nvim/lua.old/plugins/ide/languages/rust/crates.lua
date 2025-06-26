vim.api.nvim_create_autocmd("BufRead", {
    group = vim.api.nvim_create_augroup("CmpSourceCargo", { clear = true }),
    pattern = "Cargo.toml",
    callback = function()
        local success, cmp = pcall(require, "cmp")
        if not success then return end
        cmp.setup.buffer({ sources = { { name = "crates" } } })
    end,
})

local crates_dependencies = {
    'nvim-lua/plenary.nvim'
}

local crates = {
    "Saecki/crates.nvim",
    dependencies = crates_dependencies,
    config = true,
    lazy = true,
    enabled = true,
    event = { "BufRead Cargo.toml" }
}

return crates
