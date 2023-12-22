local required_mason_modules = {
    "pyright",
    "ruff-lsp",
    "debugpy",
    "black",
    "isort",
    "taplo",
}

local lsp_settings = {
    svelte = {
        filetypes = { "svelte", "html", "javascript", "typescript" },
    },
    ruff_lsp = {
        settings = {
            organizeImports = false,
        },
        on_attach = function(client)
            client.server_capabilities.hoverProvider = false
        end,
    },
}

local function mason_config()
    require("mason").setup({
        ensure_installed = required_mason_modules,
        automatic_installation = true,
        ui = {
            border = "rounded"
        },
        registries = {
            "github:nvim-java/mason-registry",
            "github:mason-org/mason-registry"
        }
    })
    require("java").setup()
    vim.api.nvim_set_hl(0, "LspInfoBorder", { fg = _G.__miversen_border_color})
    local lspconf = require("lspconfig")
    require("lspconfig.ui.windows").default_options.border = "rounded"
    local mason_lspconfig = require("mason-lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local dap = require("dap")
    local dapui = require("dapui")
    local osv = require("osv")
    local lsp_capabilities = cmp_nvim_lsp.default_capabilities()
    lsp_capabilities.textDocument.completion.completionItem.snippetSupport = true
    local lsp_handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
        ["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help,
        { border = "rounded" }
        ),
    }
    vim.fn.sign_define("DiagnosticSignError", {
        text = "",
        numhl = "DiagnosticSignError",
        texthl = "DiagnosticSignError",
    })
    vim.fn.sign_define("DiagnosticSignWarn", {
        text = "⚠",
        numhl = "DiagnosticSignWarn",
        texthl = "DiagnosticSignWarn",
    })
    vim.fn.sign_define("DiagnosticSignInformation", {
        text = "",
        numhl = "DiagnosticSignInformation",
        texthl = "DiagnosticSignInformation",
    })
    vim.fn.sign_define("DiagnosticSignHint", {
        text = "",
        numhl = "DiagnosticSignHint",
        texthl = "DiagnosticSignHint",
    })
    mason_lspconfig.setup({
        automatic_installation = true,
    })
    mason_lspconfig.setup_handlers({
        function(lsp)
            local lsp_setting = lsp_settings[lsp] or {}
            local _ = lsp_setting.on_attach
            local lsp_on_attach = function(client, bufnr)
                vim.lsp.inlay_hint.enable(bufnr, true)
                if _ then
                    _(client, bufnr)
                end
            end
            lsp_setting.on_attach = lsp_on_attach
            lsp_setting.capabilities = lsp_capabilities
            lsp_setting.handles = lsp_handlers
            lspconf[lsp].setup(lsp_setting)
        end,
        ["rust_analyzer"] = function()
            -- Purposely leaving this empty as rustaceanvim sets this up
        end,
    })
    local python_dap = require("dap-python")
    local debugpy_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python3"
    python_dap.setup(debugpy_path, {})
    vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", linehl = "", numhl = "" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "🔵", texthl = "", linehl = "", numhl = "" })
    require("dap.ext.vscode").load_launchjs()
    dapui.setup()
    dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
    end
    dap.listeners.after.event_exited["dapui_config"] = function()
        dapui.close()
    end
    local osv_port = 8086
    if not dap.launch_server then
        dap.launch_server = {}
    end
    dap.configurations.lua = {
        {
            type = "nlua",
            request = "attach",
            name = "Attach to running Neovim instance",
        },
    }
    dap.configurations[""] = dap.configurations.lua
    dap.adapters.nlua = function(callback, config)
        callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or osv_port })
    end
    dap.launch_server["nil"] = function()
        print("Starting OSV DAP Server")
        osv.launch({ port = osv_port })
    end
end

local mason_dependencies = {
    "tikhomirov/vim-glsl",
    "neovim/nvim-lspconfig", -- Neovim LSP Setup
    "williamboman/mason-lspconfig.nvim", -- Mason lsp config bindings
    "rcarriga/nvim-dap-ui", -- UI for Dap
    "mfussenegger/nvim-dap", -- Debugger, setup below
    "mfussenegger/nvim-lint", -- Neovim linter
    "mhartington/formatter.nvim", -- Neovim formatter
    "hrsh7th/cmp-nvim-lsp", -- Neovim LSP feeder for cmp
    "jbyuki/one-small-step-for-vimkind", -- Neovim Dap
    "mfussenegger/nvim-dap-python", -- Python Dap
    "mrcjkb/rustaceanvim", -- Neovim Rust Tools new?
    {
        "nvim-java/nvim-java",
        dependencies = {
            'nvim-java/lua-async-await',
            'nvim-java/nvim-java-core',
            'nvim-java/nvim-java-test',
            'nvim-java/nvim-java-dap',
        }
    }
}

local mason = {
    "williamboman/mason.nvim",
    dependencies = mason_dependencies,
    config = mason_config
}

return mason
