local function bootstrap_package_manager()
    -- Testing out lazy.nvim though this same logic can
    -- be used to pull down packer if we revert to that
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", -- latest stable release
            lazypath,
        })
    end
    vim.opt.rtp:prepend(lazypath)
end

local function get_plugins()
    local lsp_settings = {}

    local excluded_filetypes_array = {
        "lsp-installer",
        "lspinfo",
        "Outline",
        "lazy",
        "help",
        "packer",
        "netrw",
        "qf",
        "dbui",
        "Trouble",
        "fugitive",
        "floaterm",
        "spectre_panel",
        "spectre_panel_write",
        "checkhealth",
        "man",
        "dap-repl",
        "toggleterm",
        "neo-tree",
        "ImportManager",
        "aerial",
    }
    local excluded_filetypes_table = {}
    for _, value in ipairs(excluded_filetypes_array) do
        excluded_filetypes_table[value] = 1
    end
    local plugins = {
        -- Local import function
        {
            "miversen33/import.nvim",
            dir = "~/git/import.nvim",
            lazy = false,
            dev = true,
            config = function()
                require("import").config({ output_split_type = "vertical", import_enable_better_printing = true })
            end,
            priority = 1001, -- Highest priority?
        },
        -- Themes
        {
            "Mofiqul/vscode.nvim", -- Vscode type theme
            lazy = false,
            priority = 1000,
            config = {
                -- -- Enable transparent background
                -- transparent = true,

                -- Enable italic comment
                italic_comments = true,
            },
        },
        {
            "nvim-lualine/lualine.nvim", -- Neovim status line
            dependencies = {
                "kyazdani42/nvim-web-devicons",
                "SmiteshP/nvim-navic",
                "onsails/lspkind-nvim",
            },
            lazy = false,
            priority = 999,
            config = function()
                local lualine = require("lualine")
                local nvim_navic = require("nvim-navic")
                nvim_navic.setup({
                    seperator = "",
                    highlight = true,
                })
                local create_symbol_bar = function()
                    if not nvim_navic.is_available() then
                        return ""
                    end
                    local details = {}
                    for _, item in ipairs(nvim_navic.get_data()) do
                        -- For some reason sumneko adds a random ` ->` to the end of the name *sometimes*
                        -- This accounts for that I guess...
                        table.insert(details, item.icon .. item.name:gsub("%s*->%s*", ""))
                        -- Looks like we have some more weirdness coming from sumneko...
                    end
                    return table.concat(details, " > ")
                end
                local get_buf_filetype = function()
                    return vim.api.nvim_buf_get_option(0, "filetype")
                end
                local format_name = function(output)
                    if excluded_filetypes_table[get_buf_filetype()] then
                        return ""
                    end
                    return output
                end
                local branch_max_width = 40
                local branch_min_width = 10
                lualine.setup({
                    options = {
                        theme = "vscode",
                        disabled_filetypes = {
                            winbar = excluded_filetypes_array,
                        },
                        globalstatus = true,
                    },
                    sections = {
                        lualine_a = {
                            "mode",
                            {
                                "branch",
                                fmt = function(output)
                                    local win_width = vim.o.columns
                                    local max = branch_max_width
                                    if win_width * 0.25 < max then
                                        max = math.floor(win_width * 0.25)
                                    end
                                    if max < branch_min_width then
                                        max = branch_min_width
                                    end
                                    if max % 2 ~= 0 then
                                        max = max + 1
                                    end
                                    if output:len() >= max then
                                        return output:sub(1, (max / 2) - 1)
                                            .. "..."
                                            .. output:sub(-1 * ((max / 2) - 1), -1)
                                    end
                                    return output
                                end,
                            },
                        },
                        lualine_b = {
                            {
                                "filename",
                                file_status = false,
                                path = 1,
                                fmt = format_name,
                            },
                            {
                                "diagnostics",
                                update_in_insert = true,
                            },
                        },
                        lualine_c = {},
                        lualine_x = {
                            "import",
                        },
                        -- Combine x and y
                        lualine_y = {
                            {
                                function()
                                    local lsps = vim.lsp.get_active_clients({ bufnr = vim.fn.bufnr() })
                                    local icon = require("nvim-web-devicons").get_icon_by_filetype(
                                        vim.api.nvim_buf_get_option(0, "filetype")
                                    )
                                    if lsps and #lsps > 0 then
                                        local names = {}
                                        for _, lsp in ipairs(lsps) do
                                            table.insert(names, lsp.name)
                                        end
                                        return string.format("%s %s", table.concat(names, ", "), icon)
                                    else
                                        return icon or ""
                                    end
                                end,
                                on_click = function()
                                    vim.api.nvim_command("LspInfo")
                                end,
                                color = function()
                                    local _, color = require("nvim-web-devicons").get_icon_cterm_color_by_filetype(
                                        vim.api.nvim_buf_get_option(0, "filetype")
                                    )
                                    return { fg = color }
                                end,
                            },
                            "encoding",
                            "progress",
                        },
                        lualine_z = {
                            "location",
                            {
                                function()
                                    local starts = vim.fn.line("v")
                                    local ends = vim.fn.line(".")
                                    local count = starts <= ends and ends - starts + 1 or starts - ends + 1
                                    return count .. "V"
                                end,
                                cond = function()
                                    return vim.fn.mode():find("[Vv]") ~= nil
                                end,
                            },
                        },
                    },
                    inactive_sections = {
                        lualine_a = {},
                        lualine_b = {},
                        lualine_c = {
                            {
                                "filetype",
                                icon_only = true,
                            },
                            {
                                "filename",
                                path = 1,
                                fmt = format_name,
                            },
                        },
                        lualine_x = {},
                        lualine_y = {},
                        lualine_z = {},
                    },
                    winbar = {
                        lualine_a = {
                            { "filetype", icon_only = true, icon = { align = "left" } },
                            { "filename", file_status = false, path = 0 },
                        },
                        lualine_b = {},
                        lualine_c = { create_symbol_bar },
                        lualine_x = {},
                        lualine_y = {},
                        lualine_z = {},
                    },
                    inactive_winbar = {
                        lualine_a = {
                            { "filetype", icon_only = true, icon = { align = "left" } },
                            { "filename", file_status = false, path = 0 },
                        },
                        lualine_b = {},
                        lualine_c = {},
                        lualine_x = {},
                        lualine_y = {},
                        lualine_z = {},
                    },
                })
            end,
        },
        {
            "noib3/nvim-cokeline", -- Neovim Tab/Buffer Bar.
            priority = 999,
            config = function()
                local cokeline = require("cokeline")
                local colors = require("vscode.colors").get_colors()
                local get_hex = require("cokeline.utils").get_hex
                local active_bg_color = "#931E9E"
                active_bg_color = "#A066E8"
                local inactive_bg_color = colors.vscContext
                local bg_color = get_hex("ColorColumn", "bg")
                local no_error_color = "#3DEB63"
                local error_color = "#C95157"
                local warn_color = "#e1c400"
                local setup = {
                    show_if_buffers_are_at_least = 1,
                    buffers = {
                        filter_valid = function(buffer)
                            if excluded_filetypes_table[buffer.type] or excluded_filetypes_table[buffer.filetype] then
                                return false
                            end
                            return true
                        end,
                    },
                    mappings = {
                        cycle_prev_next = true,
                    },
                    default_hl = {
                        bg = function(buffer)
                            if buffer.is_focused then
                                return active_bg_color
                            else
                                return inactive_bg_color
                            end
                        end,
                    },
                    components = {
                        {
                            text = function(buffer)
                                local _text = ""
                                if buffer.index > 1 then
                                    _text = " "
                                end
                                if buffer.is_focused or buffer.is_first then
                                    _text = _text .. ""
                                end
                                return _text
                            end,
                            fg = function(buffer)
                                if buffer.is_focused then
                                    return active_bg_color
                                elseif buffer.is_first then
                                    return inactive_bg_color
                                end
                            end,
                            bg = function(buffer)
                                if buffer.is_focused then
                                    if buffer.is_first then
                                        return bg_color
                                    else
                                        return inactive_bg_color
                                    end
                                elseif buffer.is_first then
                                    return bg_color
                                end
                            end,
                        },
                        {
                            text = function(buffer)
                                local status = ""
                                if buffer.is_readonly then
                                    status = " ➖"
                                elseif buffer.is_modified then
                                    status = " "
                                end
                                return status
                            end,
                            fg = function(buffer)
                                if buffer.is_focused and (buffer.is_readonly or buffer.is_modified) then
                                    return warn_color
                                end
                            end,
                        },
                        {
                            text = function(buffer)
                                return " " .. buffer.devicon.icon
                            end,
                            fg = function(buffer)
                                if buffer.is_focused then
                                    return buffer.devicon.color
                                end
                            end,
                        },
                        {
                            text = function(buffer)
                                return buffer.unique_prefix .. buffer.filename .. " "
                            end,
                            fg = function(buffer)
                                if buffer.diagnostics.errors > 0 then
                                    return error_color
                                end
                            end,
                            style = function(buffer)
                                local text_style = "NONE"
                                if buffer.is_focused then
                                    text_style = "bold"
                                end
                                if buffer.diagnostics.errors > 0 then
                                    if text_style ~= "NONE" then
                                        text_style = text_style .. ",underline"
                                    else
                                        text_style = "underline"
                                    end
                                end
                                return text_style
                            end,
                        },
                        {
                            text = function(buffer)
                                local errors = buffer.diagnostics.errors
                                if errors <= 9 then
                                    errors = ""
                                else
                                    errors = "🙃"
                                end
                                return errors .. " "
                            end,
                            fg = function(buffer)
                                if buffer.diagnostics.errors == 0 then
                                    return no_error_color
                                elseif buffer.diagnostics.errors <= 9 then
                                    return error_color
                                end
                            end,
                        },
                        {
                            text = " ",
                            delete_buffer_on_left_click = true,
                        },
                        {
                            text = function(buffer)
                                if buffer.is_focused or buffer.is_last then
                                    return ""
                                else
                                    return " "
                                end
                            end,
                            fg = function(buffer)
                                if buffer.is_focused then
                                    return active_bg_color
                                elseif buffer.is_last then
                                    return inactive_bg_color
                                else
                                    return bg_color
                                end
                            end,
                            bg = function(buffer)
                                if buffer.is_focused then
                                    if buffer.is_last then
                                        return bg_color
                                    else
                                        return inactive_bg_color
                                    end
                                elseif buffer.is_last then
                                    return bg_color
                                end
                            end,
                        },
                    },
                }
                cokeline.setup(setup)
            end,
        },
        -- use('edluffy/specs.nvim') -- Neovim cursorline jump highlighter
        -- Utilities
        {
            "RRethy/vim-illuminate",
            config = function()
                require("illuminate").configure()
                vim.api.nvim_set_keymap(
                    "n",
                    "<C-n>",
                    ':lua require("illuminate").goto_next_reference()<CR>',
                    { silent = true, noremap = true }
                )
                vim.api.nvim_set_keymap(
                    "n",
                    "<C-N>",
                    ':lua require("illuminate").goto_prev_reference()<CR>',
                    { silent = true, noremap = true }
                )
            end,
        },
        {
            "phaazon/mind.nvim", -- Mind mapping/note taking
            dependencies = {
                "nvim-lua/plenary.nvim",
            },
            config = true,
        },
        {
            "lukas-reineke/indent-blankline.nvim", -- Neovim indentation handling
            config = {
                filetype_exclude = excluded_filetypes_array,
                show_current_context = true,
                show_current_context_start = true,
                use_treesitter = true,
            },
        },
        {
            "tami5/sqlite.lua", -- Neovim SQlite database
            lazy = true,
        },
        {
            "nvim-treesitter/nvim-treesitter", -- Neovim treesitter
            build = ":TSUpdate",
            config = function()
                require("nvim-treesitter.configs").setup({
                    -- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
                    highlight = { enable = true },
                    markid = { enable = true },
                })
            end,
        },
        {
            "nvim-telescope/telescope.nvim", -- Fuzzy Finder
            dependencies = {
                "nvim-lua/plenary.nvim",
            },
        },
        {
            "rcarriga/nvim-notify", -- Notify
            config = function()
                local notify = require("notify")
                vim.notify = notify
                notify.setup({})
            end,
        },
        {
            "ziontee113/icon-picker.nvim", -- Nerdfont picker
            dependencies = {
                "stevearc/dressing.nvim",
                "nvim-telescope/telescope.nvim",
            },
            config = true,
        },
        {
            "RaafatTurki/hex.nvim", -- Enables hex editor for neovim
            config = true,
        },
        {
            "kevinhwang91/nvim-ufo", -- Better folding? Idk we will see
            dependencies = "kevinhwang91/promise-async",
        },
        {
            "famiu/bufdelete.nvim", -- Better buffer deletion
        },
        {
            "anuvyklack/hydra.nvim", -- Keymaps
            config = function()
                require("plugins.keymaps")
            end,
        },
        {
            "mrjones2014/smart-splits.nvim", -- Neovim better split handling?
            lazy = true,
            config = {
                tmux_integration = false,
            },
        },
        {
            "stevearc/aerial.nvim", -- Better code outline??
            config = {
                ignore = { filetypes = excluded_filetypes_array },
                backends = { "treesitter", "lsp", "markdown", "man" },
                filter_kind = {
                    "Class",
                    "Constructor",
                    "Enum",
                    "Function",
                    "Interface",
                    "Module",
                    "Method",
                    "Struct",
                    "Variable",
                },
                layout = {
                    placement = "edge",
                },
                highlight_on_hover = true,
                lazy_mode = false,
                update_events = "TextChanged,InsertLeave,WinEnter,WinLeave",
                show_guides = true,
                attach_mode = "global",
            },
        },
        {
            "akinsho/toggleterm.nvim", -- Neovim Floating Terminal Framework
            config = true,
        },
        {
            "m-demare/hlargs.nvim",
            dependencies = { "nvim-treesitter/nvim-treesitter" },
            config = true,
        },
        {
            "numToStr/Comment.nvim", -- Neovim Commenting
            config = true,
        },
        {
            "ojroques/nvim-osc52", -- Neovim clipboard integration
            config = function()
                local osc52 = require("osc52")
                osc52.setup({
                    max_length = 0,
                    silent = false,
                    trim = false,
                })

                local function copy(lines, _)
                    osc52.copy(table.concat(lines, "\n"))
                end

                local function paste()
                    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
                end

                vim.keymap.set("n", "<leader>c", osc52.copy_operator, { expr = true })
                vim.keymap.set("n", "<leader>cc", "<leader>c_", { remap = true })
                vim.keymap.set("x", "<leader>c", osc52.copy_visual)

                vim.g.clipboard = {
                    name = "osc52",
                    copy = {
                        ["+"] = copy,
                        ["*"] = copy,
                    },
                    paste = {
                        ["+"] = paste,
                        ["*"] = paste,
                    },
                }
            end,
        },
        -- Language Specific
        {
            "simrat39/rust-tools.nvim", -- Rust tools specific to neovim
            config = true,
        },
        -- IDE
        {
            "nvim-pack/nvim-spectre", -- Better search and replace?
        },
        {
            "williamboman/mason.nvim", -- Neovim Language Tools (LSP, Debugger, Formatter, Linter, etc)
            dependencies = {
                "neovim/nvim-lspconfig", -- Neovim LSP Setup
                "williamboman/mason-lspconfig.nvim", -- Mason lsp config bindings
                "mfussenegger/nvim-dap", -- Debugger, setup below
                "mfussenegger/nvim-lint", -- Neovim linter
                "mhartington/formatter.nvim", -- Neovim formatter
                "SmiteshP/nvim-navic", -- Navigational helper using lspconfig
                "hrsh7th/cmp-nvim-lsp", -- Neovim LSP feeder for cmp
            },
            config = function()
                require("mason").setup()
                local lspconf = require("lspconfig")
                local mason_lspconfig = require("mason-lspconfig")
                local nvim_navic = require("nvim-navic")
                local cmp_nvim_lsp = require("cmp_nvim_lsp")
                local lsp_capabilities = cmp_nvim_lsp.default_capabilities()
                lsp_capabilities.textDocument.completion.completionItem.snippetSupport = true
                local lsp_handlers = {
                    ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
                    ["textDocument/signatureHelp"] = vim.lsp.with(
                        vim.lsp.handlers.signature_help,
                        { border = "rounded" }
                    ),
                }
                local global_on_attach = function(client, bufnr)
                    if client.server_capabilities.documentSymbolProvider then
                        nvim_navic.attach(client, bufnr)
                    end
                end
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
                            global_on_attach(client, bufnr)
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
                        require("rust-tools").setup()
                    end,
                })
                require("formatter").setup({
                    filetype = {
                        ['*'] = {
                            require("formatter.filetypes.any"),
                        },
                        lua = {
                            -- You can also define your own configuration
                            function()
                                local util = require("formatter.util")
                                -- Full specification of configurations is down below and in Vim help
                                -- files
                                return {
                                    exe = "stylua",
                                    args = {
                                        "--indent-type",
                                        "Spaces",
                                        "--search-parent-directories",
                                        "--stdin-filepath",
                                        util.escape_path(util.get_current_buffer_file_path()),
                                        "--",
                                        "-",
                                    },
                                    stdin = true,
                                }
                            end,
                        },
                    },
                })
            end,
        },
        {
            "theHamsta/nvim-dap-virtual-text", -- Neovim DAP Virutal Text lol what else do you think this is?'
            build = ":TSUpdate",
        },
        {
            "hrsh7th/nvim-cmp", -- Neovim autocompletion
            dependencies = {
                "rcarriga/cmp-dap", -- Neovim autocomplete for dap
                "L3MON4D3/LuaSnip", -- Neovim Lua based snippet manager
                "saadparwaiz1/cmp_luasnip", -- Neovim LuaSnip autocompletion engine for nvim-cmp
                "hrsh7th/cmp-nvim-lsp", -- vim/neovim snippet stuffs
                "KadoBOT/cmp-plugins", -- Neovim plugin autocompletion
                "hrsh7th/cmp-buffer", -- vim/neovim snippet stuffs
                "hrsh7th/cmp-path", -- vim/neovim snippet stuffs
                "hrsh7th/cmp-cmdline", -- vim/neovim snippet stuffs
                "hrsh7th/cmp-nvim-lsp-signature-help",
                "windwp/nvim-autopairs", -- Auto pairs
                "theHamsta/nvim-dap-virtual-text", -- Neovim DAP Virutal Text lol what else do you think this is?
                "ray-x/cmp-treesitter", -- Neovim snippet for treesitter (Maybe replace the buffer completion?)
            },
            config = function()
                local cmp = require("cmp")
                local luasnip = require("luasnip")
                local lspkind = require("lspkind")
                local cmp_dap = require("cmp_dap")
                local cmp_plugins = require("cmp-plugins")
                local nvim_autopairs = require("nvim-autopairs")
                local ndvt = require("nvim-dap-virtual-text")
                local cmp_autopairs = require("nvim-autopairs.completion.cmp")
                ndvt.setup()
                nvim_autopairs.setup({
                    disabled_filetypes = excluded_filetypes_array,
                })
                cmp_plugins.setup({ files = { ".*\\.lua" } })
                luasnip.config.set_config({ history = true, update_events = "TextChanged,TextChangedI" })
                require("luasnip.loaders.from_vscode").lazy_load()
                local confirm_mapping = function(fallback)
                    if luasnip.expandable() then
                        return luasnip.expand()
                    end
                    if cmp and cmp.visible() and cmp.get_active_entry() then
                        cmp.confirm({
                            behavior = cmp.ConfirmBehavior.Replace,
                            select = false,
                        })
                        return
                    end
                    fallback()
                end
                local next_option_mapping = function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    else
                        fallback()
                    end
                end
                local previous_option_mapping = function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    else
                        fallback()
                    end
                end
                cmp.setup({
                    enabled = function()
                        return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt" or cmp_dap.is_dap_buffer()
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
                        ["<Enter>"] = confirm_mapping,
                        ["<Tab>"] = cmp.mapping({
                            i = confirm_mapping,
                            c = next_option_mapping,
                        }),
                        ["<Down>"] = cmp.mapping(next_option_mapping, { "i" }),
                        ["<Up>"] = cmp.mapping(previous_option_mapping, { "i" }),
                        ["<S-Tab>"] = cmp.mapping(previous_option_mapping, { "c" }),
                        ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
                        ["<C-Up>"] = cmp.mapping(cmp.mapping.scroll_docs(-4)),
                        ["<C-Down>"] = cmp.mapping(cmp.mapping.scroll_docs(4)),
                        ["<Esc>"] = cmp.mapping({
                            i = cmp.abort(),
                            c = cmp.close(),
                        }),
                    },
                    sources = cmp.config.sources({
                        { name = "nvim_lsp" },
                        { name = "plugins" },
                        { name = "luasnip", option = { show_autosnippets = true } }, -- For luasnip users.
                        { name = "nvim_lsp_signature_help" },

                        { name = "dictionary", keyword_length = 2 },
                        { name = "path" },
                        -- { name = "treesitter" }
                    }, {
                        { name = "buffer" },
                    }),
                })

                cmp.setup.cmdline("/", {
                    sources = {
                        { name = "buffer" },
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
            end,
        },
        {
            "nvim-neo-tree/neo-tree.nvim", -- File Explorer
            branch = "v2.x",
            dependencies = {
                "nvim-lua/plenary.nvim",
                "kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
                "MunifTanjim/nui.nvim",
            },
            dir = "~/git/neo-tree.nvim",
            dev = true,
            config = {
                sources = {
                    "filesystem",
                    "buffers",
                    "netman.ui.neo-tree",
                },
                filesystem = {
                    filtered_items = {
                        visible = true,
                        hide_gitignored = false,
                        hide_hidden = false,
                        hide_dotfiles = false,
                    },
                    follow_current_file = true,
                },
            },
        },
        {
            "miversen33/netman.nvim", -- Remove Resource Browser
            dir = "~/git/netman.nvim",
            dev = true,
            branch = "v1.1",
            config = function()
                require("netman")
            end,
        },
        {
            "folke/lsp-colors.nvim", -- Neovim create missing lsp color highlight groups
            config = true,
        },
        {
            url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
            config = function()
                require("lsp_lines").setup()
                vim.diagnostic.config({ virtual_text = false })
            end,
        },
        {
            "haringsrob/nvim_context_vt",
            config = {
                highlight = "FloatTitle",
            },
        },
        {
            "uga-rosa/ccc.nvim",
            config = {
                highlighter = {
                    auto_enable = true,
                    excludes = excluded_filetypes_array,
                },
            },
        },
        {
            "kevinhwang91/nvim-bqf",
            ft = "qf",
            config = true,
        },
        {
            "hkupty/iron.nvim",
            config = function()
                require("iron.core").setup({
                    config = {
                        scratch_repl = true,
                        repl_definition = {
                            sh = {
                                command = { "zsh" },
                            },
                            lua = {
                                command = { "croissant" },
                            },
                        },
                        repl_open_cmd = require("iron.view").split.vertical("42%"),
                    },
                    highlight = {
                        italic = true,
                    },
                    ignore_blank_lines = true,
                })
            end,
        },
        {
            -- miversen fork of hover to make it quiet
            'miversen33/hover.nvim',
            dir = "~/git/hover.nvim",
            dev = true,
            config = function()
                require("hover").setup({
                    init = function()
                        require("hover.providers.lsp")
                    end,
                    preview_opts = {
                        border = 'rounded'
                    },
                    auto = true,
                    quiet = true,
                    excluded_fts = excluded_filetypes_array,
                    -- Whether the contents of a currently open hover window should be moved
                    -- to a :h preview-window when pressing the hover keymap.
                    preview_window = false,
                        title = true
                })
                -- -- Setup keymaps
                vim.api.nvim_create_autocmd({'CursorHold'},
                    {
                        callback = function()
                          local ft = vim.api.nvim_buf_get_option(0, 'filetype')
                            if not excluded_filetypes_table[ft] then
                                require("hover").hover()
                            end
                        end
                    }
                )
                vim.keymap.set("n", "K", require("hover").hover, {desc = "hover.nvim"})
                vim.keymap.set("n", "gK", require("hover").hover_select, {desc = "hover.nvim (select)"})
            end
        },
        -- Keep both and lets see which we prefer
        {
            "ellisonleao/glow.nvim",
            config = true,
            cmd = "Glow"
        },
        {
            "toppair/peek.nvim",
            build = "deno task --quiet build:fast",
            config = true,
        }
        -- Debugger
    }
    for _, plugin in ipairs(plugins) do
        -- Check if 'dev' is enabled, if it is, check if the directory it points to exists
        -- if it doesn't, switch dev to false
        if plugin.dev then
            local dir_glob = vim.fn.glob(plugin.dir)
            if not plugin.dir or not dir_glob or dir_glob:len() == 0 then
                plugin.dev = false
                plugin.dir = nil
            end
        end
    end
    return plugins
end

local function setup_plugins()
    -- Currently using lazy, though we might use packer instead
    local plugins = get_plugins()
    require("lazy").setup(plugins)
    require("custom_plugins") -- Load local plugins
end

bootstrap_package_manager()
setup_plugins()
