local neo_tree = {
    "nvim-neo-tree/neo-tree.nvim", -- File Explorer
    branch = "main",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
        "onsails/lspkind-nvim", -- Document Symbols
    },
    config = function()
        local lspkind = require("lspkind")
        vim.api.nvim_set_hl(0, "NeoTreeCursorLine", { bold = true, underline = true })
        local neo_tree = require("neo-tree")
        local config = {
            popup_border_style = "rounded",
            source_selector = {
                winbar = true,
                sources = {
                    { source = "filesystem" },
                    { source = "buffers" },
                    { source = "document_symbols" },
                    { source = "remote" },
                },
            },
            default_component_configs = {
                name = {
                    highlight_opened_files = "all",
                },
            },
            sources = {
                "filesystem",
                "buffers",
                "document_symbols",
                "netman.ui.neo-tree",
            },
            buffers = {
                bind_to_cwd = false,
            },
            filesystem = {
                filtered_items = {
                    visible = true,
                    hide_gitignored = false,
                    hide_hidden = false,
                    hide_dotfiles = false,
                },
                follow_current_file = {
                    enabled = true,
                },
                window = {
                    mappings = {
                        ["/"] = "noop"
                    }
                }
            },
            log = {
                level = "debug",
            },
            close_if_last_window = true
        }
        neo_tree.setup(config)
    end
}

return neo_tree
