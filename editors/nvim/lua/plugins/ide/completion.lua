local function config()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")
    local has_cmp_dap, cmp_dap = pcall(require, "cmp_dap")
    local has_cmp_plugins, cmp_plugins = pcall(require, "cmp-plugins")
    local has_autopairs, nvim_autopairs = pcall(require, "nvim-autopairs")
    local cmp_autopairs = has_autopairs and require("nvim-autopairs.completion.cmp")
    local has_dap_vt, ndvt = pcall(require, "nvim-dap-virtual-text")
    if has_dap_vt then
        ndvt.setup()
    end
    if has_autopairs then
        nvim_autopairs.setup({
            disabled_filetypes = _G.__miversen_excluded_filetypes_array,
        })
    end
    if has_cmp_plugins then
        cmp_plugins.setup({ files = { ".*\\.lua" } })
    end

    luasnip.config.set_config({ history = true, update_events = "TextChanged,TextChangedI" })
    require("luasnip.loaders.from_vscode").lazy_load()
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
            return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt" or (has_cmp_dap and cmp_dap.is_dap_buffer())
        end,
        formatting = {
            format = lspkind.cmp_format(),
        },
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body) -- For `luasnip` users.
            end,
        },
        mapping = {
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                else
                    fallback()
                end
            end, { "i", "s", "c" }),
            ["<Down>"] = cmp.mapping(next_option_mapping, { "i" }),
            ["<Up>"] = cmp.mapping(previous_option_mapping, { "i" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
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
            { name = "luasnip", option = { show_autosnippets = true } }, -- For luasnip users.
            { name = "nvim_lsp_signature_help" },

            { name = "dictionary", keyword_length = 2 },
            { name = "path" },
            { name = "treesitter" },
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
            { name = "cmdline" },
        }),
    })
    cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
        sources = { name = "dap" },
    })
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end
local dependencies = {
    "rcarriga/cmp-dap", -- Neovim autocomplete for dap
    "L3MON4D3/LuaSnip", -- Neovim Lua based snippet manager
    "saadparwaiz1/cmp_luasnip", -- Neovim LuaSnip autocompletion engine for nvim-cmp
    "hrsh7th/cmp-nvim-lsp", -- vim/neovim snippet stuffs
    "hrsh7th/cmp-buffer", -- vim/neovim snippet stuffs
    "hrsh7th/cmp-path", -- vim/neovim snippet stuffs
    "hrsh7th/cmp-cmdline", -- vim/neovim snippet stuffs
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "windwp/nvim-autopairs", -- Auto pairs
    "theHamsta/nvim-dap-virtual-text", -- Neovim DAP Virutal Text lol what else do you think this is?
    "ray-x/cmp-treesitter", -- Neovim snippet for treesitter (Maybe replace the buffer completion?)
    "Saecki/crates.nvim", -- Neovim crates snippet/completion engine
}

local completion = {{
    "hrsh7th/nvim-cmp",
    dependencies = dependencies,
    config = config
}}

return completion
