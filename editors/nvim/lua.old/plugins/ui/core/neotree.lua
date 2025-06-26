local neotree_opts = {
            auto_clean_after_session_restore = true,
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
                        ["/"] = "noop",
                        ["<Left>"] = function(state)
                            if not state or not state.tree then return end -- Nothing to do if we didn't get a state
                            vim.schedule(function()
                                require("neo-tree.ui.renderer").focus_node(state, state.tree:get_node():get_parent_id())
                            end)
                        end
                    }
                }
            },
            log = {
                level = "debug",
            },
            close_if_last_window = true
        }

---@module "lazy"
---@type LazySpec
return {
    "nvim-neo-tree/neo-tree.nvim", -- File Explorer
    branch = "main",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
        "onsails/lspkind-nvim", -- Document Symbols
    },
    config = function()
        vim.api.nvim_set_hl(0, "NeoTreeCursorLine", { bold = true, underline = true })
        local neo_tree = require("neo-tree")
        neo_tree.setup(neotree_opts)
    end
}
