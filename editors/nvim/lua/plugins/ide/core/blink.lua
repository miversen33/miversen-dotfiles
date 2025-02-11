vim.api.nvim_set_hl(0, 'BlinkCmpMenuBorder', { fg = _G.__miversen_border_color })
vim.api.nvim_set_hl(0, "BlinkCmpLabelDeprecated", { fg = "#7E8294", bg = "NONE", strikethrough = true })
vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { fg = "#82AAFF", bg = "NONE", bold = true })
vim.api.nvim_set_hl(0, "BlinkCmpMenu", { fg = "#C792EA", bg = "NONE", italic = true })

vim.api.nvim_set_hl(0, "BlinkCmpKindField", { fg = "#EED8DA", bg = "#B5585F" })
vim.api.nvim_set_hl(0, "BlinkCmpKindProperty", { fg = "#EED8DA", bg = "#B5585F" })
vim.api.nvim_set_hl(0, "BlinkCmpKindEvent", { fg = "#EED8DA", bg = "#B5585F" })

vim.api.nvim_set_hl(0, "BlinkCmpKindText", { fg = "#C3E88D", bg = "#9FBD73" })
vim.api.nvim_set_hl(0, "BlinkCmpKindEnum", { fg = "#C3E88D", bg = "#9FBD73" })
vim.api.nvim_set_hl(0, "BlinkCmpKindKeyword", { fg = "#C3E88D", bg = "#9FBD73" })

vim.api.nvim_set_hl(0, "BlinkCmpKindConstant", { fg = "#FFE082", bg = "#D4BB6C" })
vim.api.nvim_set_hl(0, "BlinkCmpKindConstructor", { fg = "#FFE082", bg = "#D4BB6C" })
vim.api.nvim_set_hl(0, "BlinkCmpKindReference", { fg = "#FFE082", bg = "#D4BB6C" })

vim.api.nvim_set_hl(0, "BlinkCmpKindFunction", { fg = "#EADFF0", bg = "#A377BF" })
vim.api.nvim_set_hl(0, "BlinkCmpKindStruct", { fg = "#EADFF0", bg = "#A377BF" })
vim.api.nvim_set_hl(0, "BlinkCmpKindClass", { fg = "#EADFF0", bg = "#A377BF" })
vim.api.nvim_set_hl(0, "BlinkCmpKindModule", { fg = "#EADFF0", bg = "#A377BF" })
vim.api.nvim_set_hl(0, "BlinkCmpKindOperator", { fg = "#EADFF0", bg = "#A377BF" })

vim.api.nvim_set_hl(0, "BlinkCmpKindVariable", { fg = "#C5CDD9", bg = "#7E8294" })
vim.api.nvim_set_hl(0, "BlinkCmpKindFile", { fg = "#C5CDD9", bg = "#7E8294" })

vim.api.nvim_set_hl(0, "BlinkCmpKindUnit", { fg = "#F5EBD9", bg = "#D4A959" })
vim.api.nvim_set_hl(0, "BlinkCmpKindSnippet", { fg = "#F5EBD9", bg = "#D4A959" })
vim.api.nvim_set_hl(0, "BlinkCmpKindFolder", { fg = "#F5EBD9", bg = "#D4A959" })

vim.api.nvim_set_hl(0, "BlinkCmpKindMethod", { fg = "#DDE5F5", bg = "#6C8ED4" })
vim.api.nvim_set_hl(0, "BlinkCmpKindValue", { fg = "#DDE5F5", bg = "#6C8ED4" })
vim.api.nvim_set_hl(0, "BlinkCmpKindEnumMember", { fg = "#DDE5F5", bg = "#6C8ED4" })

vim.api.nvim_set_hl(0, "BlinkCmpKindInterface", { fg = "#D8EEEB", bg = "#58B5A8" })
vim.api.nvim_set_hl(0, "BlinkCmpKindColor", { fg = "#D8EEEB", bg = "#58B5A8" })
vim.api.nvim_set_hl(0, "BlinkCmpKindTypeParameter", { fg = "#D8EEEB", bg = "#58B5A8" })


---@module "lazy"
---@type LazySpec
return {
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    version = '0.11.0',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        keymap = { preset = 'default' },

        appearance = {
            use_nvim_cmp_as_default = true,
            nerd_font_variant = 'mono',
        },
        completion = {
            menu = { border = 'rounded' },
            documentation = { window = { border = 'rounded' } }
        },
        signature = { window = { border = 'rounded' } },
        sources = {
            default = {'lsp', 'path', 'snippets', 'buffer' }
        }
    },
    opts_extended = { 'sources.default' }
}
