local snippets_dir = vim.fn.stdpath("config") .. "/snippets"

local scissor_opts = {
    snippetDir = snippets_dir
}

local scissors = {
    "chrisgrieser/nvim-scissors",
    dependencies = "nvim-telescope/telescope.nvim",
    config = true,
    opts = scissor_opts
}

return scissors
