local function config()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")
    local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
    local has_cmp_dap, cmp_dap = pcall(require, "cmp_dap")
    local has_cmp_plugins, cmp_plugins = pcall(require, "cmp-plugins")
    local has_autopairs, nvim_autopairs = pcall(require, "nvim-autopairs")
    local cmp_autopairs = has_autopairs and require("nvim-autopairs.completion.cmp")
    local has_dap_vt, ndvt = pcall(require, "nvim-dap-virtual-text")
    local has_nvim_highlight_colors, nvim_highlight_colors = pcall(require, "nvim-highlight-colors")
    if has_dap_vt then
        ndvt.setup()
    end
    if not has_devicons then
        -- Devicons not available, niling out the item so we can do other logic
        devicons = nil
    end
    if has_autopairs then
        nvim_autopairs.setup({
            disabled_filetypes = _G.__miversen_config_excluded_filetypes_array,
        })
    end
    if has_cmp_plugins then
        cmp_plugins.setup({ files = { ".*\\.lua" } })
    end

    -- Thanks hrsh7th, very cool
    -- https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance#how-to-get-types-on-the-left-and-offset-the-menu
    -- Customization for Pmenu
    -- Weird side-effect of this is dropbar looks kinda fucky now
    vim.api.nvim_set_hl(0, "Custom_CmpFloatBorder", { fg = _G.__miversen_border_color })
    vim.api.nvim_set_hl(0, "Custom_CmpItemAbbrDeprecated", { fg = "#7E8294", bg = "NONE", strikethrough = true })
    vim.api.nvim_set_hl(0, "Custom_CmpItemAbbrMatch", { fg = "#82AAFF", bg = "NONE", bold = true })
    vim.api.nvim_set_hl(0, "Custom_CmpItemAbbrMatchFuzzy", { fg = "#82AAFF", bg = "NONE", bold = true })
    vim.api.nvim_set_hl(0, "Custom_CmpItemMenu", { fg = "#C792EA", bg = "NONE", italic = true })

    vim.api.nvim_set_hl(0, "Custom_CmpItemKindField", { fg = "#EED8DA", bg = "#B5585F" })
    vim.api.nvim_set_hl(0, "Custom_CmpItemKindProperty", { fg = "#EED8DA", bg = "#B5585F" })
    vim.api.nvim_set_hl(0, "Custom_CmpItemKindEvent", { fg = "#EED8DA", bg = "#B5585F" })

    vim.api.nvim_set_hl(0, "Custom_CmpItemKindText", { fg = "#C3E88D", bg = "#9FBD73" })
    vim.api.nvim_set_hl(0, "Custom_CmpItemKindEnum", { fg = "#C3E88D", bg = "#9FBD73" })
    vim.api.nvim_set_hl(0, "Custom_CmpItemKindKeyword", { fg = "#C3E88D", bg = "#9FBD73" })

    vim.api.nvim_set_hl(0, "Custom_CmpItemKindConstant", { fg = "#FFE082", bg = "#D4BB6C" })
    vim.api.nvim_set_hl(0, "Custom_CmpItemKindConstructor", { fg = "#FFE082", bg = "#D4BB6C" })
    vim.api.nvim_set_hl(0, "Custom_CmpItemKindReference", { fg = "#FFE082", bg = "#D4BB6C" })

    vim.api.nvim_set_hl(0, "Custom_CmpItemKindFunction", { fg = "#EADFF0", bg = "#A377BF" })
    vim.api.nvim_set_hl(0, "Custom_CmpItemKindStruct", { fg = "#EADFF0", bg = "#A377BF" })
    vim.api.nvim_set_hl(0, "Custom_CmpItemKindClass", { fg = "#EADFF0", bg = "#A377BF" })
    vim.api.nvim_set_hl(0, "Custom_CmpItemKindModule", { fg = "#EADFF0", bg = "#A377BF" })
    vim.api.nvim_set_hl(0, "Custom_CmpItemKindOperator", { fg = "#EADFF0", bg = "#A377BF" })

    vim.api.nvim_set_hl(0, "Custom_CmpItemKindVariable", { fg = "#C5CDD9", bg = "#7E8294" })
    vim.api.nvim_set_hl(0, "Custom_CmpItemKindFile", { fg = "#C5CDD9", bg = "#7E8294" })

    vim.api.nvim_set_hl(0, "Custom_CmpItemKindUnit", { fg = "#F5EBD9", bg = "#D4A959" })
    vim.api.nvim_set_hl(0, "Custom_CmpItemKindSnippet", { fg = "#F5EBD9", bg = "#D4A959" })
    vim.api.nvim_set_hl(0, "Custom_CmpItemKindFolder", { fg = "#F5EBD9", bg = "#D4A959" })

    vim.api.nvim_set_hl(0, "Custom_CmpItemKindMethod", { fg = "#DDE5F5", bg = "#6C8ED4" })
    vim.api.nvim_set_hl(0, "Custom_CmpItemKindValue", { fg = "#DDE5F5", bg = "#6C8ED4" })
    vim.api.nvim_set_hl(0, "Custom_CmpItemKindEnumMember", { fg = "#DDE5F5", bg = "#6C8ED4" })

    vim.api.nvim_set_hl(0, "Custom_CmpItemKindInterface", { fg = "#D8EEEB", bg = "#58B5A8" })
    vim.api.nvim_set_hl(0, "Custom_CmpItemKindColor", { fg = "#D8EEEB", bg = "#58B5A8" })
    vim.api.nvim_set_hl(0, "Custom_CmpItemKindTypeParameter", { fg = "#D8EEEB", bg = "#58B5A8" })

    luasnip.setup({
        enable_autosnippets = true,
        history = true,
        update_events = "TextChanged,TextChangedI"
    })
    require("luasnip.loaders.from_vscode").lazy_load({paths = { vim.fn.stdpath("config") .. "/snippets" }})
    local next_option_mapping = function(fallback)
        if cmp.visible() and cmp.get_active_entry() then
            cmp.select_next_item()
        else
            fallback()
        end
    end
    local previous_option_mapping = function(fallback)
        if cmp.visible() and cmp.get_active_entry() then
            cmp.select_prev_item()
        else
            fallback()
        end
    end
    cmp.setup({
        enabled = function()
            local context = require("cmp.config.context")
            local is_prompt = vim.api.nvim_get_option_value('buftype', {buf = 0}) == 'prompt'
            local is_comment = context.in_treesitter_capture('comment') and context.in_syntax_group('Comment')
            return not is_prompt and not is_comment
        end,
        formatting = {
            fields = { "kind", "abbr", "menu" },
            format = function(entry, vim_item)
                color_item = nil
                if has_nvim_highlight_colors then
                    color_item = nvim_highlight_colors.format(entry, { kind = vim_item.kind })
                end
                local kind = lspkind.cmp_format({
                    mode = "symbol_text",
                    maxwidth = 50
                })(entry, vim_item)
                local s = vim.split(kind.kind, "%s", { trimempty = true })
                if not s[2] then
                    s[2] = s[1]
                    s[1] = " "
                end
                kind.kind = string.format(" %s ", s[1])
                kind.menu = string.format(" (%s)", s[2])
                if has_nvim_highlight_colors and color_item and color_item.abbr_hl_group then
                    kind.kind_hl_group = color_item.abbr_hl_group
                    kind.kind = color_item.abbr
                end
                return kind
            end
            -- }),
        },
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body) -- For `luasnip` users.
            end,
        },
        view = {
            entries = {
                name = "custom", selection_order = "near_cursor"
            }
        },
        window = {
            completion = {
                winhighlight = "Normal:Pmenu,CmpFloatBorder:Custom_CmpFloatBorder,FloatBorder:Custom_CmpFloatBorder,Search:NONE,CursorLine:PmenuSel,CmpItemAbbrDeprecated:Custom_CmpItemAbbrDeprecated,CmpItemAbbrMatch:Custom_CmpItemAbbrMatch,CmpItemAbbrMatchFuzzy:Custom_CmpItemAbbrMatchFuzzy,CmpItemMenu:Custom_CmpItemMenu,CmpItemKindField:Custom_CmpItemKindField,CmpItemKindProperty:Custom_CmpItemKindProperty,CmpItemKindEvent:Custom_CmpItemKindEvent,CmpItemKindText:Custom_CmpItemKindText,CmpItemKindEnum:Custom_CmpItemKindEnum,CmpItemKindKeyword:Custom_CmpItemKindKeyword,CmpItemKindConstant:Custom_CmpItemKindConstant,CmpItemKindConstructor:Custom_CmpItemKindConstructor,CmpItemKindReference:Custom_CmpItemKindReference,CmpItemKindFunction:Custom_CmpItemKindFunction,CmpItemKindStruct:Custom_CmpItemKindStruct,CmpItemKindClass:Custom_CmpItemKindClass,CmpItemKindModule:Custom_CmpItemKindModule,CmpItemKindOperator:Custom_CmpItemKindOperator,CmpItemKindVariable:Custom_CmpItemKindVariable,CmpItemKindFile:Custom_CmpItemKindFile,CmpItemKindUnit:Custom_CmpItemKindUnit,CmpItemKindSnippet:Custom_CmpItemKindSnippet,CmpItemKindFolder:Custom_CmpItemKindFolder,CmpItemKindMethod:Custom_CmpItemKindMethod,CmpItemKindValue:Custom_CmpItemKindValue,CmpItemKindEnumMember:Custom_CmpItemKindEnumMember,CmpItemKindInterface:Custom_CmpItemKindInterface,CmpItemKindColor:Custom_CmpItemKindColor,CmpItemKindTypeParameter:Custom_CmpItemKindTypeParameter",
                col_offset = -3,
                side_padding = 0,
                border = "rounded"
            },
            documentation = {
                winhighlight = "Normal:Pmenu,FloatBorder:CmpFloatBorder,Search:NONE",
                border = "rounded"
            }
        },
        mapping = {
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expand_or_locally_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end, { "i", "s", "c" }),
            ["<Down>"] = cmp.mapping(next_option_mapping, { "i" }),
            ["<Up>"] = cmp.mapping(previous_option_mapping, { "i" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.locally_jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { "i", "s", "c" }),
            ["<C-Up>"] = cmp.mapping(cmp.mapping.scroll_docs(-4)),
            ["<C-Down>"] = cmp.mapping(cmp.mapping.scroll_docs(4)),
        },
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "plugins" },
            { name = "luasnip",                option = { show_autosnippets = true } }, -- For luasnip users.
            { name = "nvim_lsp_signature_help" },

            { name = "dictionary",             keyword_length = 2 },
            { name = "path" },
            { name = "treesitter" },
            { name = "lazydev", group_index = 0 },
        }, {
            { name = "buffer" },
        }),
    })

    cmp.setup.cmdline("/", {
        sources = {
            { name = "buffer" },
            { name = "treesitter" },
        },
    })
    cmp.setup.cmdline(":", {
        sources = cmp.config.sources({
            { name = "path" },
        }, {
            { name = "cmdline", keyword_pattern = [=[[^[:blank:]\!]*]=] },
        }),
    })
    cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
        sources = { name = "dap" },
    })
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end

local autopairs_opts = {}

local dependencies = {
    "rcarriga/cmp-dap",                -- Neovim autocomplete for dap
    {
        "L3MON4D3/LuaSnip",                -- Neovim Lua based snippet manager
        build = "make install_jsregexp"
    },
    "onsails/lspkind-nvim",            -- lspkind for lsp icons
    "saadparwaiz1/cmp_luasnip",        -- Neovim LuaSnip autocompletion engine for nvim-cmp
    "hrsh7th/cmp-nvim-lsp",            -- vim/neovim snippet stuffs
    "hrsh7th/cmp-buffer",              -- vim/neovim snippet stuffs
    "hrsh7th/cmp-path",                -- vim/neovim snippet stuffs -- consider switching to "FelipeLema/cmp-async-path"?
    "hrsh7th/cmp-cmdline",             -- vim/neovim snippet stuffs
    "hrsh7th/cmp-nvim-lsp-signature-help",
    {
        "windwp/nvim-autopairs",           -- Auto pairs
        opts = autopairs_opts,
    },
    "theHamsta/nvim-dap-virtual-text", -- Neovim DAP Virutal Text lol what else do you think this is?
    "ray-x/cmp-treesitter",            -- Neovim snippet for treesitter (Maybe replace the buffer completion?)
    "Saecki/crates.nvim",              -- Neovim crates snippet/completion engine
}

local completion = {
    "hrsh7th/nvim-cmp",
    dependencies = dependencies,
    config = config,
    event = "VeryLazy"
}

return completion
