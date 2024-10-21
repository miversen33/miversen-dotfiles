local material_opts = {
    lualine_style = "default",
    high_visibility = {
        darker = true
    },
    styles = {
        comments = {
            italic = true
        }
    },
    plugins = {
        "dap",
        "fidget",
        "gitsigns",
        "illuminate",
        "neo-tree",
        "nvim-cmp",
        "nvim-web-devicons",
        "trouble",
        "nvim-notify"
    },
    custom_highlights = function(color)
        return {
            Constant = { bold = true, fg = color.main.cyan },
            Number = { fg = color.main.orange },
            Boolean = { fg = color.main.orange },
            ['@constant'] = { link = "Constant" },
            ['@constant.builtin'] = { link = "@constant" },
            ['@lsp.typemod.variable.defaultLibrary'] = { link = "Constant" },
            ['@lsp.mod.defaultLibrary'] = { link = "Constant" },

            -- I just cannot figure out what color I want this to be...
            Parameter = { fg = '#E6D47C', bold = true, italic = true },
            ['@variable.parameter'] = { link = "Parameter" },
            ['@lsp.type.parameter'] = { link = "Parameter" },
            ['@lsp.typemod.parameter'] = { link = "Parameter"},

            Conditional = { fg = color.main.blue },
            ['@keyword'] = { fg = color.main.darkpurple },
            Type = { fg = color.main.lightpurple, underline = true },
            ['@type'] = { link = 'Type' },
            ['@label'] = { fg = color.main.paleblue, bold = true },
            ['@keyword.return'] = { fg = color.main.lightpurple },
            ['@keyword.exception'] = { fg = color.main.lightpurple },
        }
    end,
    custom_colors = function(color)
        color.main.darkpurple = '#8D67A6'
        color.main.purple = '#AD7ECC'
        color.main.lightpurple = '#CD96F2'
        color.main.darkred = '#EA6D54'
        color.main.red = '#F07178'
        color.main.lightred = '#F0908E'
        color.main.darkorange = '#A66933'
        color.main.orange = '#CC813F'
        color.main.lightorange = '#F2994B'
        color.main.darkyellow = '#E6D244'
        color.main.yellow = '#FFCB6B'
        color.main.lightyellow = '#FFE19F'
        color.main.darkgreen = '#50A658'
        color.main.green = '#62CC6C'
        color.main.lightgreen = '#74F281'
        color.main.darkblue = '#556EA6'
        color.main.blue = '#6888CC'
        color.main.lightblue = '#7CA1F2'
        color.main.cyan = '#89DDFF'
        color.main.paleblue = '#8DA1CC'
    end,
}

-- Other options
-- vim.g.material_style = "darker"
-- vim.g.material_style = "lighter"
-- vim.g.material_style = "oceanic"
-- vim.g.material_style = "palenight"
vim.g.material_style = "deep ocean"

-- Uncomment this if you want to set the theme to material
-- vim.g.__miversen_set_theme('material')

---@module "lazy"
---@type LazySpec
return {
    "marko-cerovac/material.nvim", -- Material theme
    priority = 1000,
    lazy = false,
    opts = material_opts
}
