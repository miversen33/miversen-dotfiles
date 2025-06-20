vim.api.nvim_set_hl( 0, "LspInfoBorder", { fg = _G.__miversen_border_color } )
vim.fn.sign_define( "DiagnosticSignError", {
    text = "",
    numhl = "DiagnosticSignError",
    texthl = "DiagnosticSignError"
} )
vim.fn.sign_define( "DiagnosticSignWarn", {
    text = "⚠",
    numhl = "DiagnosticSignWarn",
    texthl = "DiagnosticSignWarn"
} )
vim.fn.sign_define( "DiagnosticSignInformation", {
    text = "",
    numhl = "DiagnosticSignInformation",
    texthl = "DiagnosticSignInformation"
} )
vim.fn.sign_define( "DiagnosticSignHint", {
    text = "",
    numhl = "DiagnosticSignHint",
    texthl = "DiagnosticSignHint"
} )

-- There is probably a better way to do this but whatever
if vim.diagnostic and vim.diagnostic.config then
    vim.diagnostic.config({
            virtual_lines = { current_line = true },
    })
end

local lsp_handlers = {
    ["textDocument/hover"] = vim.lsp.with( vim.lsp.handlers.hover,
                                           { border = "rounded" } ),
    ["textDocument/signatureHelp"] = vim.lsp.with( vim.lsp.handlers
                                                       .signature_help,
                                                   { border = "rounded" } )
}

local required_bricks = {
    "basedpyright", "lua_ls", "ruff", "debugpy", "isort",
    "prettier", "shfmt", "clang-format"
}

local manual_bricks = {
    "nushell"
}

local lsp_settings = {
    svelte = {
        settings = { filetypes = { "svelte" } },
        enabled = true
    },
    html = {
        settings = { filetypes = { "html", "svelte" } },
        enabled = true
    },
    emmet_language_server = {
        settings = { filetypes = { "html", "svelte" } },
        enabled = true
    },
    ruff = {
        enabled = true
    },
    nushell = {
        enabled = true
    },
    jdtls = {
        settings = {
            settings = {
                -- https://github.com/eclipse-jdtls/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
                java = { inlayHints = { parameterNames = { enabled = true } } }
            }
        },
        enabled = true
    },
    lua_ls = {
        settings = {
            settings = {
                -- https://luals.github.io/wiki/settings/
                Lua = { hint = { enable = true, setType = true } }
            }
        },
        enabled = true
    },
    tailwindcss = {
        settings = {
            filetypes = {
                "aspnetcorerazor", "astro", "astro-markdown", "blade", "clojure",
                "django-html", "htmldjango", "edge", "eelixir", "elixir", "ejs",
                "erb", "eruby", "gohtml", "gohtmltmpl", "haml", "handlebars", "hbs",
                "html", "htmlangular", "html-eex", "heex", "jade", "leaf", "liquid",
                "mdx", "mustache", "njk", "nunjucks", "php", "razor", "slim",
                "twig", "css", "less", "postcss", "sass", "scss", "stylus",
                "sugarss", "javascript", "javascriptreact", "reason", "rescript",
                "typescript", "typescriptreact", "vue", "svelte", "templ"
            }
        },
        enabled = true
    },
    basedpyright = {
        settings = {
            settings = {
                basedpyright = {
                    -- https://docs.basedpyright.com/#/configuration
                    analysis = {
                        typeCheckingMode = "standard",
                        diagnosticSeverityOverrides = {
                            reportAssignmentType = false,
                            reportArgumentType = "information",
                            reportUnusedFunction = "information",
                            reportOptionalMemberAccess = "information",
                            reportRedeclaration = "information",
                            reportImplicitOverride = false,
                            reportAny = false
                        }
                    },
                    venvPath = "./venv"
                }
            }
        },
        enabled = true
    },
}

local conform = {
    "stevearc/conform.nvim",
    opts = {
        formatters_by_ft = {
            python = { "isort", "ruff server" },
            lua = { "lua-format" },
            rust = { "rustfmt" },
            html = { "prettier" },
            javascript = { "prettier" },
            css = { "prettier" },
            svelte = { "prettier" },
            c = { "clang-format" },
            cpp = { "clang-format" },
            java = { "clang-format" },
            sh = { "shfmt" },
            bash = { "shfmt" },
            zsh = { "shfmt" }
        },
        formatters = {
            ---@module "conform"
            ---@type conform.FiletypeFormatter
            ["lua-format"] = {
                args = {
                    "--indent-width=4", "--column-limit=80",
                    "--continuation-indent-width=4", "--no-use-tab",
                    "--indent-width=4", "--keep-simple-control-block-one-line",
                    "--keep-simple-function-one-line", "--align-args",
                    "--no-break-after-functioncall-lp",
                    "--no-break-before-functioncall-rp", "--align-parameter",
                    "--no-break-after-functiondef-lp",
                    "--no-break-before-functiondef-rp", "--align-table-field",
                    "--break-after-table-lb", "--break-before-table-rb",
                    "--single-quote-to-double-quote",
                    "--spaces-inside-functiondef-parens",
                    "--spaces-inside-functioncall-parens",
                    "--spaces-inside-table-braces",
                    "--spaces-around-equals-in-field", "$FILENAME"
                },
                ---@module "conform"
                ---@type conform.FiletypeFormatter
                ["prettier"] = { "prettier", args = { "--use-tabs=false" } },

                ---@module "conform"
                ---@type conform.FiletypeFormatter
                ["clang-format"] = { "clang-format", args = {} },

                ---@module "conform"
                ---@type conform.FiletypeFormatter
                ["shfmt"] = { "shfmt", args = {} },

                ---@module "conform"
                ---@type conform.FiletypeFormatter
                ["ruff server"] = { "ruff server", args = {} }

            }
        }
    }

}



local mason = {
    "williamboman/mason.nvim",
    lazy = false,
    opts = {
        max_concurrent_installers = 8,
        registries = {
            "github:nvim-java/mason-registry", "github:mason-org/mason-registry"
        },
        ui = { border = "rounded" }
    }
}

local lsp = {
    "neovim/nvim-lspconfig",
    config = function()
        require( "lspconfig.ui.windows" ).default_options.border = "rounded"
    end
}

local neotest = {
    "nvim-neotest/neotest",
    dependencies = {
        { "nvim-neotest/nvim-nio" },
        { "nvim-lua/plenary.nvim" },
        { "antoinemadec/FixCursorHold.nvim" },
        { "nvim-treesitter/nvim-treesitter" },
        { "nvim-neotest/neotest-python" },
        -- { "fredrikaverpil/neotest-golang" },
        -- { "rcasia/neotest-java" },
        -- { "marilari88/neotest-vitest" },
        -- { "mrcjkb/rustaceanvim" }, -- This is unnecessary, rustaceanvim is already installed in plugins.ide.languages.rust
        -- { "rcasia/neotest-bash" },
        -- { "alfaix/neotest-gtest" }, -- c++ testing
        -- { "lawrence-laz/neotest-zig" },
        -- { "mrcjkb/neotest-haskell" },
   },
   config = function()
       -- We have to use config here to prevent failure on loading as the various
       -- neotest adapters are not downloaded/loaded
       require("neotest").setup({
           adapters = {
               require( "neotest-python" ),
               -- require( "neotest-golang" ),
               -- require( "neotest-java" ),
               -- require( "neotest-vitest" ),
               -- require( "neotest-bash" ),
               -- require( "neotest-gtest" ),
               -- require( "neotest-zig" ),
               -- require( "rustaceanvim.neotest"),
               -- require( "neotest-haskell" ),
           }
       })
   end
}

local dap = { "mfussenegger/nvim-dap" }

local dap_ui = {
    "rcarriga/nvim-dap-ui",
    dependencies = { dap, "nvim-neotest/nvim-nio" },
    config = function()
        local _dap, dapui = require( "dap" ), require( "dapui" )
        dapui.setup()
        vim.fn.sign_define( "DapBreakpoint", {
            text = "🔴",
            texthl = "",
            linehl = "",
            numhl = ""
        } )
        vim.fn.sign_define( "DapBreakpointCondition", {
            text = "🔵",
            texthl = "",
            linehl = "",
            numhl = ""
        } )
        _dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        _dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        _dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        _dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end
        require("dap.ext.vscode").load_launchjs()
        -- IDK why but dapui puts a black background on its NC highlight groups. Fixing that now
        local dapuinc_hl_groups = {"DapUIUnavailableNC", "DapUIPlayPauseNC", "DapUIStepOverNC", "DapUIStepIntoNC", "DapUIStepBackNC", "DapUIStepOutNC", "DapUIRestartNC", "DapUINormalNC", "DapUIStopNC"}
        for _, hl_name in ipairs(dapuinc_hl_groups) do
            local hl = vim.api.nvim_get_hl(0, {name = hl_name})
            hl.bg = "NONE"
            vim.api.nvim_set_hl(0, hl_name, hl)
        end
        -- -- Adds a telescope filepicker for selecting the debug executable
        -- _dap.configurations.cpp = {
        --     {
        --         name = "Launch an executable",
        --         type = "cppdbg",
        --         request = "launch",
        --         cwd = "${workspaceFolder}",
        --         program = function()
        --             local opts = {}
        --             return coroutine.create( function( coro )
        --                 require("telescope.pickers").new( opts, {
        --                     prompt_title = "Path to executable",
        --                     finder = require("telescope.finders").new_oneshot_job( {
        --                         "fd", "--hidden", "--no-ignore", "--type", "x"
        --                     }, {} ),
        --                     sorter = require("telescope.config").values.generic_sorter( opts ),
        --                     attach_mappings = function( buffer_number )
        --                         require("telescope.actions").select_default:replace( function()
        --                             require("telescope.actions").close( buffer_number )
        --                             coroutine.resume( coro,
        --                                               require("telescope.actions.state").get_selected_entry()[1] )
        --                         end )
        --                         return true
        --                     end
        --                 } ):find()
        --             end )
        --         end
        --     }
        -- }
        -- local hover_cmd = nil
        -- _dap.listeners.after.event_initialized['me'] = function()
        --     hover_cmd = vim.api.nvim_create_autocmd('CursorHold', {
        --         callback = function()
        --             require("dap.ui.widgets").hover()
        --         end
        --     })
        -- end
        -- _dap.listeners.after.event_terminated['me'] = function()
        --     pcall(vim.api.nvim_del_autocmd, hover_cmd)
        -- end
    end
}

local mason_lsp = {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { mason, lsp, "saghen/blink.cmp" },
    opts = { automatic_installation = true },
    init = function()
        local lsp_capabilities =
            require( "blink.cmp" ).get_lsp_capabilities()
        lsp_capabilities.textDocument.completion.completionItem.snippetSupport =
            true

        local lspconfig = require( "lspconfig" )
        for _, brick in ipairs(manual_bricks) do
            local mortar = lsp_settings[brick] or {}
            lspconfig.nushell.setup(mortar)
        end
    end
}

local mason_dap = {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { mason, dap, dap_ui },
    opts = { automatic_installation = true },
    config = true
}

local mason_conform = {
    "zapling/mason-conform.nvim",
    priority = 900,
    dependencies = { mason, conform }
}

local mason_java = {
    "nvim-java/nvim-java",
    dependencies = {
        "nvim-java/lua-async-await", "nvim-java/nvim-java-refactor",
        "nvim-java/nvim-java-core", "nvim-java/nvim-java-test",
        "nvim-java/nvim-java-dap", "MunifTanjim/nui.nvim"
    }
}

local mason_installer_opts = {
    run_on_start = true,
    ensure_installed = required_bricks
}

local mason_installer = {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { mason_lsp, mason_dap, mason_conform, mason_java, neotest },
    opts = mason_installer_opts
}


for lsp_name, lsp_setting in pairs(lsp_settings) do
    vim.lsp.config(lsp_name, lsp_setting.settings or {})
    if lsp_setting.enabled then
        vim.lsp.enable(lsp_name)
    end
end

vim.lsp.inlay_hint.enable(true)

-- vim.keymap.set(
--     'n',
--     '\\', 
-- function()
--         local cursor_position = vim.api.nvim_win_get_cursor(0)
--         local line_num = cursor_position[1]
--         local buffer = vim.api.nvim_get_current_buf()
--         local diag = vim.diagnostic.get(buffer, {lnum = line_num})
--         if #diag == 0 then
--             print(diag)
--         end
--     end,
--     {silent = true})
--
-- vim.api.nvim_create_autocmd('CursorHold', {
--     callback = function()
--         vim.diagnostic.open_float({ source = "if_many" })
--     end,
-- })

-- vim.api.nvim_create_autocmd("LspAttach", {
--     group = _G.__miversen_augroup,
--     callback = function(args)
--         local client = vim.lsp.get_client_by_id(args.data.client_id)
--         if not client then
--             vim.log.debug("LSP client not found for attached buffer")
--             return
--         end
--         -- vim.lsp.inlay_hint.enable(true, {bufnr = args.buf})
-- --     function( lsp_server )
--         --         local lsp_setting = lsp_settings[lsp_server] or {}
--         --         local _ = lsp_setting.on_attach
--         --         local lsp_on_attach = function( client, bufnr )
--         --             vim.lsp.inlay_hint.enable( true, { bufnr = bufnr } )
--         --             if _ then _( client, bufnr ) end
--         --         end
--         --         lsp_setting.on_attach = lsp_on_attach
--         --         lsp_setting.capabilities = lsp_capabilities
--         --         lsp_setting.handles = lsp_handlers
--         --         lspconfig[lsp_server].setup( lsp_setting )
--         --     end,
--         --     ["rust_analyzer"] = function()
--         --         -- Purposely stubbing rust_analyzer out so rustaceanvim can do what it does
--         --         -- instead
--         --     end
--         -- if client_settings and client_settings.enabled then
--
--     end
-- })
return mason_installer
