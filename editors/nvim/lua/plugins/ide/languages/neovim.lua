---@module "lazy"
---@type LazySpec
local lazydev = {
    {
        -- "folke/lazydev.nvim",
        "FelipeLema/lazydev.nvim", -- Using this until upstream has proper emmy_lua support
        ft = "lua",                -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    { -- optional blink completion source for require statements and module annotations
        "saghen/blink.cmp",
        opts = {
            sources = {
                -- add lazydev to your completion providers
                default = { "lazydev", "lsp", "path", "snippets", "buffer" },
                providers = {
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        -- make lazydev completions top priority (see `:h blink.cmp`)
                        score_offset = 100,
                    },
                },
            },
        },
    },
    { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
    { "LuaCATS/luassert",     name = "luassert-types", lazy = true },
    { "LuaCATS/busted",       name = "busted-types",   lazy = true },
    -- { "folke/neodev.nvim", enabled = false }, -- make sure to uninstall or disable neodev.nvim
}

return lazydev
