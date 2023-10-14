local venv_selector = {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        "nvim-telescope/telescope.nvim",
        "mfussenegger/nvim-dap-python"
    },
    opts = {
        dap_enabled = true
    },
    ft = "python"
}

return venv_selector
