vim.g.catppuccin_flavour = "mocha" -- latte, frappe, macchiato, mocha

import('catppuccin', function(catppuccin)
    catppuccin.setup({
        transparent_background=false,
        term_colors=true,
        compile = {
            enabled = false,
            path = vim.fn.stdpath("cache") .. "/catppuccin",
        },
        dim_inactive = {
            enabled = true,
            shade = "dark",
            percentage = 0.50,
        },
        integrations = {
            "aerial",
            "notify",
            "treesitter",
            indent_blankline = {
                enabled = true,
                colored_indent_levels = false
            }
        }
    })
    vim.cmd("colorscheme catppuccin")
end)

-- vim.g.vscode_style = 'dark'
-- vim.g.vscode_transparent = 1
-- vim.g.vscode_italic_comment = 1
-- vim.cmd('colorscheme vscode')
-- import('onedarkpro', function(onedarkpro)
--     local onedark = 'onedark'
--     local onelight = 'onelight'
--     local onedark_vivid = 'onedark_vivid'
--     local onelight_vivid = 'onelight_vivid'
--
--     local dark_theme = onedark_vivid
--     local light_theme = onelight
--     onedarkpro.setup({
--         -- Theme can be overwritten with 'onedark' or 'onelight' as a string
--         theme = function()
--           if vim.o.background == "dark" then
--               return dark_theme
--           else
--               return light_theme
--           end
--         end,
--         colors = {}, -- Override default colors by specifying colors for 'onelight' or 'onedark' themes
--         hlgroups = {}, -- Override default highlight groups
--         filetype_hlgroups = {}, -- Override default highlight groups for specific filetypes
--         styles = {
--             -- strings = "NONE", -- Style that is applied to strings
--             -- comments = "NONE", -- Style that is applied to comments
--             -- keywords = "NONE", -- Style that is applied to keywords
--             -- functions = "NONE", -- Style that is applied to functions
--             -- variables = "NONE", -- Style that is applied to variables
--             -- virtual_text = "NONE", -- Style that is applied to virtual text
--         },
--         options = {
--             bold = true, -- Use the themes opinionated bold styles?
--             italic = true, -- Use the themes opinionated italic styles?
--             underline = true, -- Use the themes opinionated underline styles?
--             undercurl = true, -- Use the themes opinionated undercurl styles?
--             cursorline = true, -- Use cursorline highlighting?
--             transparency = true, -- Use a transparent background?
--             terminal_colors = false, -- Use the theme's colors for Neovim's :terminal?
--             window_unfocussed_color = true, -- When the window is out of focus, change the normal background?
--         }
--     })
--     onedarkpro.load()
--     end
-- )
