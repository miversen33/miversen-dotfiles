vim.g.rustaceanvim = {
    server = {
        on_attach = function(_, bufnr)
            print("Connecting to rust buffer")
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end,
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
}

local rustaceanvim = {
    "mrcjkb/rustaceanvim",
    ft = {"rust"},
    version = "^4",
}

return rustaceanvim
