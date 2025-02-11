vim.api.nvim_set_hl(0, 'BlinkCmpMenuBorder', { fg = _G.__miversen_border_color })
vim.api.nvim_set_hl(0, "BlinkCmpLabelDeprecated", { fg = "#7E8294", bg = "NONE", strikethrough = true })
vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { fg = "#82AAFF", bg = "NONE", bold = true })
vim.api.nvim_set_hl(0, "BlinkCmpMenu", { fg = "#C792EA", bg = "NONE", italic = true })
vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { fg = "#7E8294", bg = "NONE" })

-- vim.api.nvim_set_hl(0, "BlinkCmpKindField", { fg = "#B5585F" })
-- vim.api.nvim_set_hl(0, "BlinkCmpKindProperty", { fg = "#B5585F" })
-- vim.api.nvim_set_hl(0, "BlinkCmpKindEvent", { fg = "#B5585F" })
--
-- vim.api.nvim_set_hl(0, "BlinkCmpKindText", { fg = "#9FBD73" })
-- vim.api.nvim_set_hl(0, "BlinkCmpKindEnum", { fg = "#9FBD73" })
-- vim.api.nvim_set_hl(0, "BlinkCmpKindKeyword", { fg = "#9FBD73" })
--
-- vim.api.nvim_set_hl(0, "BlinkCmpKindConstant", { fg = "#D4BB6C" })
-- vim.api.nvim_set_hl(0, "BlinkCmpKindConstructor", { fg = "#D4BB6C" })
-- vim.api.nvim_set_hl(0, "BlinkCmpKindReference", { fg = "#D4BB6C" })
--
-- vim.api.nvim_set_hl(0, "BlinkCmpKindFunction", { fg = "#A377BF" })
-- vim.api.nvim_set_hl(0, "BlinkCmpKindStruct", { fg = "#A377BF" })
-- vim.api.nvim_set_hl(0, "BlinkCmpKindClass", { fg = "#A377BF" })
-- vim.api.nvim_set_hl(0, "BlinkCmpKindModule", { fg = "#A377BF" })
-- vim.api.nvim_set_hl(0, "BlinkCmpKindOperator", { fg = "#A377BF" })
--
-- vim.api.nvim_set_hl(0, "BlinkCmpKindVariable", { fg = "#7E8294" })
-- vim.api.nvim_set_hl(0, "BlinkCmpKindFile", { fg = "#7E8294" })
--
-- vim.api.nvim_set_hl(0, "BlinkCmpKindUnit", { fg = "#D4A959" })
-- vim.api.nvim_set_hl(0, "BlinkCmpKindSnippet", { fg = "#D4A959" })
-- vim.api.nvim_set_hl(0, "BlinkCmpKindFolder", { fg = "#D4A959" })
--
-- vim.api.nvim_set_hl(0, "BlinkCmpKindMethod", { fg = "#6C8ED4" })
-- vim.api.nvim_set_hl(0, "BlinkCmpKindValue", { fg = "#6C8ED4" })
-- vim.api.nvim_set_hl(0, "BlinkCmpKindEnumMember", { fg = "#6C8ED4" })
--
-- vim.api.nvim_set_hl(0, "BlinkCmpKindInterface", { fg = "#58B5A8" })
-- vim.api.nvim_set_hl(0, "BlinkCmpKindColor", { fg = "#58B5A8" })
-- vim.api.nvim_set_hl(0, "BlinkCmpKindTypeParameter", { fg = "#58B5A8" })


---@module "lazy"
---@type LazySpec
return {
    'saghen/blink.cmp',
    dependencies = {'rafamadriz/friendly-snippets'},
    version = '*',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
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
                -- "select_and_accept", "fallback",

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
            }
        },
        appearance = {
            use_nvim_cmp_as_default = true,
            nerd_font_variant = 'mono',
        },
        completion = {
            ghost_text = {
                enabled = true
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 500,
                window = {
                    border = 'rounded'
                },
            },
            menu = {
                border = 'rounded',
                draw = {
                    columns = {
                        { 'kind_icon', gap = 1 },
                        { "label", "label_description", gap = 1 },
                        { 'kind' },
                        { 'source_name' },
                        { 'source_id' }
                    },
                    -- components = {
                    --     label = {
                    --         ---@module 'blink.cmp.completion.windows.render.context'
                    --         ---@param ctx blink.cmp.DrawItemContext
                    --         highlight = function(ctx)
                    --             highlight = vim.api.nvim_get_hl(0, { name = ctx.item }) or {}
                    --             if not highlight.fg then
                    --                 return {}
                    --             end
                    --             return {
                    --                 ctx.item,
                    --                 range = 5
                    --             }
                    --         end
                    --     }
                    -- },
                    -- components = {
                    --     kind_icon = function(ctx)
                    --         print(ctx)
                    --         return ctx
                    --     end
                    -- },
                    treesitter = { 'lsp' }
                },
            },
        },
        signature = {
            window = { border = 'rounded' },
            -- enabled = true,
        },
        sources = {
            default = {'lsp', 'path', 'snippets', 'buffer' },
            providers = {
                lazydev = {
                    name = "LazyDev",
                    module = "lazydev.integrations.blink",
                    score_offset = 100
                }
            }
        }
    },
    opts_extended = { 'sources.default' }
}
