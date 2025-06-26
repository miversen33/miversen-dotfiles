vim.api.nvim_set_hl(0, 'BlinkCmpMenuBorder', { fg = _G.__miversen_border_color })
vim.api.nvim_set_hl(0, "BlinkCmpLabelDeprecated", { fg = "#7E8294", strikethrough = true })
vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { fg = "#82AAFF", bold = true })
vim.api.nvim_set_hl(0, "BlinkCmpMenu", { fg = "#C792EA", italic = true })
vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { fg = "#7E8294" })

vim.api.nvim_set_hl(0, "BlinkCmpKindField", { fg = "#B5585F" })
vim.api.nvim_set_hl(0, "BlinkCmpKindProperty", { fg = "#B5585F" })
vim.api.nvim_set_hl(0, "BlinkCmpKindEvent", { fg = "#B5585F" })

vim.api.nvim_set_hl(0, "BlinkCmpKindText", { fg = "#9FBD73" })
vim.api.nvim_set_hl(0, "BlinkCmpKindEnum", { fg = "#9FBD73" })
vim.api.nvim_set_hl(0, "BlinkCmpKindKeyword", { fg = "#9FBD73" })

vim.api.nvim_set_hl(0, "BlinkCmpKindConstant", { fg = "#D4BB6C" })
vim.api.nvim_set_hl(0, "BlinkCmpKindConstructor", { fg = "#D4BB6C" })
vim.api.nvim_set_hl(0, "BlinkCmpKindReference", { fg = "#D4BB6C" })

vim.api.nvim_set_hl(0, "BlinkCmpKindFunction", { fg = "#A377BF" })
vim.api.nvim_set_hl(0, "BlinkCmpKindStruct", { fg = "#A377BF" })
vim.api.nvim_set_hl(0, "BlinkCmpKindClass", { fg = "#A377BF" })
vim.api.nvim_set_hl(0, "BlinkCmpKindModule", { fg = "#A377BF" })
vim.api.nvim_set_hl(0, "BlinkCmpKindOperator", { fg = "#A377BF" })

vim.api.nvim_set_hl(0, "BlinkCmpKindVariable", { fg = "#7E8294" })
vim.api.nvim_set_hl(0, "BlinkCmpKindFile", { fg = "#7E8294" })

vim.api.nvim_set_hl(0, "BlinkCmpKindUnit", { fg = "#D4A959" })
vim.api.nvim_set_hl(0, "BlinkCmpKindSnippet", { fg = "#D4A959" })
vim.api.nvim_set_hl(0, "BlinkCmpKindFolder", { fg = "#D4A959" })

vim.api.nvim_set_hl(0, "BlinkCmpKindMethod", { fg = "#6C8ED4" })
vim.api.nvim_set_hl(0, "BlinkCmpKindValue", { fg = "#6C8ED4" })
vim.api.nvim_set_hl(0, "BlinkCmpKindEnumMember", { fg = "#6C8ED4" })

vim.api.nvim_set_hl(0, "BlinkCmpKindInterface", { fg = "#58B5A8" })
vim.api.nvim_set_hl(0, "BlinkCmpKindColor", { fg = "#58B5A8" })
vim.api.nvim_set_hl(0, "BlinkCmpKindTypeParameter", { fg = "#58B5A8" })

---@module 'blink.cmp'
---@type blink.cmp.Config
local blink_opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = {
        preset = 'default',
        ["<C-Space>"] = {
            ---@module 'blink.cmp'
            ---@param cmp blink.cmp.API
            function(cmp)
                if cmp.is_menu_visible() then
                    cmp.select_and_accept()
                else
                    cmp.show()
                end
            end
        },
        ["<C-Up>"] = {
            ---@module 'blink.cmp'
            ---@param cmp blink.cmp.API
            function(cmp)
                cmp.scroll_documentation_up(4)
            end
        },
        ["<C-Down>"] = {
            ---@module 'blink.cmp'
            ---@param cmp blink.cmp.API
            function(cmp)
                cmp.scroll_documentation_down(4)
            end
        },
        ["<Esc>"] = {
            ---@module 'blink.cmp'
            ---@param cmp blink.cmp.API
            function(cmp)
                if cmp.is_menu_visible() then
                    cmp.cancel()
                end
            end, "fallback"
        }
    },

    appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono'
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = {
        keyword = {
            range = 'full'
        },

        documentation = {
            auto_show = true,
            auto_show_delay_ms = 500,
            window = {
                border = "rounded"
            }
        },
        completion = {
            menu = {
                draw = {
                    components = {
                        kind_icon = {
                            text = function(ctx)
                                local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
                                return kind_icon
                            end,
                            -- (optional) use highlights from mini.icons
                            highlight = function(ctx)
                                local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                                return hl
                            end,
                        },
                        kind = {
                            -- (optional) use highlights from mini.icons
                            highlight = function(ctx)
                                local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                                return hl
                            end,
                        }
                    }
                }
            }
        }
        -- menu = {
        --     border = 'rounded',
        --     draw = {
        --         columns = {
        --             { 'kind_icon', gap = 1 },
        --             { "label", "label_description", gap = 1 },
        --             { 'kind' },
        --             { 'source_name' },
        --         },
        --         treesitter = { 'lsp' }
        --     },
        -- },
    },
    signature = {
        window = { border = 'rounded' },
        enabled = true
    },
    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" }
}


---@type LazySpec
local blink = {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = { 'rafamadriz/friendly-snippets' },

    -- use a release tag to download pre-built binaries
    version = '1.*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    opts = blink_opts,
    opts_extend = { "sources.default" }
}

return blink

