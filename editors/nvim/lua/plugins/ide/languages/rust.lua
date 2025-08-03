---@type LazySpec
return {
    'mrcjkb/rustaceanvim',
    config = function()
        ---@type rustaceanvim.Opts
        vim.g.rustaceanvim = {
            ---@type rustaceanvim.lsp.ClientOpts
            server = {
                auto_attach = true,
                -- We should probably deal with the fact that the binary may not be installed yet
                cmd = function()
                    local binary_path = vim.g._config.languages.rust.lsps.rust_analyzer.get_binary_path()
                    if not binary_path or binary_path == 'MISSING BINARY' then
                        vim.notify("Unable to locate rust-analyzer binary for rustaceanvim", vim.log.levels.WARN, {})
                    end
                    return { binary_path }
                end,
                on_attach = function(_, bufnr)
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                end,
            },
            default_settings = {
                ["rust-analyzer"] = {
                    imports = {
                        granularity = {
                            group = "module",
                        },
                        prefix = "self",
                    },
                    cargo = {
                        buildScripts = {
                            enable = true,
                        },
                    },
                    procMacro = {
                        enable = true
                    },
                }
            }
        }
    end,
    version = '^6', -- Recommended
    lazy = false,   -- This plugin is already lazy
}
