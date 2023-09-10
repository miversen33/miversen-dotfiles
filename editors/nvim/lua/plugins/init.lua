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
    -- These are sourced with the start of the lsp server in mason
    local lsp_settings = {
        svelte = {
            filetypes = {"svelte", "html"}
        }
    }

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
        "TelescopePrompt",
        ""
    }
    local excluded_filetypes_table = {}
    for _, value in ipairs(excluded_filetypes_array) do
        excluded_filetypes_table[value] = 1
    end
    local active_bg = '#A066E8'
    local plugins = {
        -- Local import function
        {
            "miversen33/import.nvim",
            lazy = false,
            dev = true,
            config = function()
                require("import").config({ output_split_type = "vertical", import_enable_better_printing = true })
            end,
            priority = 1001, -- Highest priority?
        },
        -- General Utilities
        {
            "folke/trouble.nvim",
            config = true
        },
        {
            "kevinhwang91/nvim-hlslens",
            config = function()
                local hlslens = require("hlslens")
                hlslens.setup({
                    override_lens = function(render, posList, nearest, idx, relIdx)
                        local sfw = vim.v.searchforward == 1
                        local indicator, text, chunks
                        local absRelIdx = math.abs(relIdx)
                        if absRelIdx > 1 then
                            indicator = ('%d%s'):format(absRelIdx, sfw ~= (relIdx > 1) and '▲' or '▼')
                        elseif absRelIdx == 1 then
                            indicator = sfw ~= (relIdx == 1) and '▲' or '▼'
                        else
                            indicator = ''
                        end

                        local lnum, col = unpack(posList[idx])
                        if nearest then
                            local cnt = #posList
                            if indicator ~= '' then
                                text = ('[%s %d/%d]'):format(indicator, idx, cnt)
                            else
                                text = ('[%d/%d]'):format(idx, cnt)
                            end
                            chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLensNear' } }
                        else
                            text = ('[%s %d]'):format(indicator, idx)
                            chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLens' } }
                        end
                        render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
                    end
                })
            end
        },
        -- Themes
        {
            "Mofiqul/vscode.nvim", -- Vscode type theme
            lazy = false,
            priority = 1000,
            config = function()
                local vscode = require("vscode")
                vscode.setup({
                    -- Enable transparent background
                    transparent = true,

                    -- Enable italic comment
                    italic_comments = true,
                    group_overrides = {
                        CursorLine = { underline = true }
                    }
                })
                vscode.load()
                local colors = require("vscode.colors")
                vim.api.nvim_set_hl(0, 'NeoTreeFileNameOpened', { bg = colors.vscSelection, fg = colors.vscBack, bold = true, underline = true, italic = true })
            end
        },
        {
            'nvim-zh/colorful-winsep.nvim',
            config = function()
                local winsep = require("colorful-winsep")
                local bg = require("vscode.colors").get_colors().vscBack
                winsep.setup({
                    highlight = {
                        fg = active_bg,
                        bg = bg
                    },
                    no_exec_files = excluded_filetypes_array,
                    -- Rounded corners gud
                    symbols = { "─", "│", "╭", "╮", "╰", "╯" },
                })
            end
        },
        {
            "nvim-lualine/lualine.nvim", -- Neovim status line
            dependencies = {
                "kyazdani42/nvim-web-devicons",
                "onsails/lspkind-nvim",
                "f-person/git-blame.nvim"
            },
            lazy = false,
            priority = 999,
            config = function()
                vim.g.gitblame_display_virtual_text = 0
                local lualine = require("lualine")
                local git_blame = require("gitblame")
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
                                        .. output:sub( -1 * ((max / 2) - 1), -1)
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
                        lualine_c = {
                            {
                                git_blame.get_current_blame_text,
                                cond = git_blame.is_blame_text_available,
                                color = { fg = '#ABABAB', gui='italic'}
                            }
                        },
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
                                        return string.format("%s %s", table.concat(names, ", "), icon or '')
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
                })
            end,
        },
        {
            "willothy/nvim-cokeline", -- Neovim Tab/Buffer Bar.
            dependencies = {
                "nvim-lua/plenary.nvim",
                "kyazdani42/nvim-web-devicons",
                "Mofiqul/vscode.nvim"
            },
            config = true,
            opts = function(cokeline)
                local get_hex = require('cokeline/utils').get_hex
                local colors = require("vscode.colors").get_colors()
                local line_background = 'NONE'
                -- Needs light mode color
                active_bg = colors["vscViolet"]
                local active_bg_color = active_bg
                local inactive_bg_color = colors["vscBlack"]
                local warn_color = colors["vscGitStageModified"]
                local error_color = colors["vscGitConflicting"]
                local max_error_limit = 9
                local setup = {
                    mappings = {
                        cycle_prev_next = true
                    },
                    fill_hl = "BufferLineFill",
                    default_hl = {
                        -- fg = function(buffer)
                        --     return buffer.is_focused
                        --     and get_hex('ColorColumn', 'bg')
                        --     or get_hex('Normal', 'fg')
                        -- end,
                        bg = function(buffer)
                            return
                            buffer.is_focused and active_bg_color
                            or inactive_bg_color
                        end,
                    },
                    components = {
                        {
                            text = function(buffer)
                                return
                                buffer.is_focused and "" or " "
                            end,
                            fg = inactive_bg_color, -- line_background, -- This should be line_background but due to a bug, we cant
                            bg = function(buffer)
                                return
                                buffer.is_focused and active_bg_color
                                or inactive_bg_color
                            end,
                            style = function(buffer)
                                return
                                buffer.is_hovered and "undercurl"
                            end
                        },
                        {
                            text = function(buffer)
                                return
                                buffer.is_readonly and " "
                                or buffer.is_modified and " "
                                or " "
                            end,
                            fg = function(buffer)
                                return
                                buffer.is_focused and (buffer.is_readonly or buffer.is_modified) and warn_color
                            end,
                        },
                        {
                            text = function(buffer) return buffer.devicon.icon end,
                            fg = function(buffer) return buffer.devicon.color end,
                        },
                        {
                            text = function(buffer) return buffer.unique_prefix end,
                            fg = get_hex('Comment', 'fg'),
                            style = 'italic',
                        },
                        {
                            text = function(buffer) return buffer.filename .. ' ' end,
                            style = function(buffer)
                                if buffer.is_hovered and not buffer.is_focused then
                                    return 'underline'
                                end
                            end
                        },
                        {
                            text = function(buffer)
                                local errors = buffer.diagnostics.errors
                                if errors == 0 then
                                    errors = ""
                                elseif errors <= max_error_limit then
                                    errors = ""
                                else
                                    errors = "🙃"
                                end
                                return errors .. " "
                            end,
                            fg = function(buffer)
                                return
                                buffer.diagnostics.errors > 0 and buffer.diagnostics.errors <= max_error_limit and error_color
                            end
                        },
                        {
                            text = '',
                            on_click = function(_, _, _, _, buffer)
                                buffer:delete()
                            end
                        },
                        {
                            text = function(buffer)
                                return
                                buffer.is_focused and ""
                                or ""
                            end,
                            bg = function(buffer)
                                return
                                buffer.is_focused and line_background
                                or get_hex('ColorColumn', 'bg')
                            end,
                            fg = function(buffer)
                                return
                                buffer.is_focused and active_bg_color
                                or inactive_bg_color
                            end,
                        }
                    }
                }
                return setup
            end
        },
        {
            "leafOfTree/vim-svelte-plugin",
            config = function()
                vim.g.vim_svelte_plugin_load_full_syntax = 1
            end
        },
        {
            -- TODO: Mike, fork this and make it stable maybe?
            'edluffy/specs.nvim',
            config = function()
                local success, colors = pcall(require, 'vscode.colors')
                local bg = colors and colors.Violet or '#646695'
                local fg = colors and colors.Gray or '#808080'
                vim.api.nvim_set_hl(0, 'Specs', {
                    fg = fg,
                    bg = bg,
                })
                local specs = require("specs")
                specs.setup({
                    show_jumps = true,
                    popup = {
                        delay_ms = 5,
                        inc_ms = 10,
                        width = 20,
                        fader = specs.pulse_fader,
                        resizer = specs.slide_resizer,
                        winhl = 'Specs'
                    },
                    ignore_filetypes = excluded_filetypes_array,
                    ignore_buftypes = { nofile = true, prompt=true },
                })
            end
        },
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
            'shellRaining/hlchunk.nvim',
            event = {"UIEnter"},
            enabled = true,
            config = {
                indent = {
                    enable = false,
                    use_treesitter = true
                },
                context = {
                    enable = true,
                    use_treesitter = true
                },
                chunk = {
                    enable = true,
                    use_treesitter = true
                },
                blank = {
                    enable = false,
                    use_treesitter = true
                },
                line_num = {
                    enable = true,
                    use_treesitter = true
                }
            }
        },
        {
            "kkharji/sqlite.lua", -- Neovim SQlite database
            lazy = true,
        },
        {
            "nvim-treesitter/nvim-treesitter", -- Neovim treesitter
            dependencies = {
                'nvim-treesitter/playground'
            },
            build = ":TSUpdate|TSInstall query",
            config = function()
                require("nvim-treesitter.configs").setup({
                    -- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
                    highlight = { enable = true },
                    markid = { enable = true },
                    playground = {
                        enable = true,
                        disable = {},
                        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
                        persist_queries = false, -- Whether the query persists across vim sessions
                        keybindings = {
                            toggle_query_editor = 'o',
                            toggle_hl_groups = 'i',
                            toggle_injected_languages = 't',
                            toggle_anonymous_nodes = 'a',
                            toggle_language_display = 'I',
                            focus_language = 'f',
                            unfocus_language = 'F',
                            update = 'R',
                            goto_node = '<cr>',
                            show_help = '?',
                        },
                    },
                    query_linter = {
                        enable = true,
                        use_virtual_text = true,
                        lint_events = {"BufWrite", "CursorHold"},
                    },
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
                notify.setup({
                    background_colour = '#1e1e1e'
                })
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
                vim.api.nvim_set_hl(0, "NormalFloat", {fg="NONE", bg="NONE"})
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
        -- IDE
        {
            "nvim-pack/nvim-spectre", -- Better search and replace?
        },
        {
            "williamboman/mason.nvim", -- Neovim Language Tools (LSP, Debugger, Formatter, Linter, etc)
            dependencies = {
                "tikhomirov/vim-glsl",
                "neovim/nvim-lspconfig", -- Neovim LSP Setup
                "williamboman/mason-lspconfig.nvim", -- Mason lsp config bindings
                "rcarriga/nvim-dap-ui", -- UI for Dap
                "mfussenegger/nvim-dap", -- Debugger, setup below
                "mfussenegger/nvim-lint", -- Neovim linter
                "mhartington/formatter.nvim", -- Neovim formatter
                "hrsh7th/cmp-nvim-lsp", -- Neovim LSP feeder for cmp
                "jbyuki/one-small-step-for-vimkind", -- Neovim Dap
                "simrat39/rust-tools.nvim", -- Neovim Rust Tools
                "mfussenegger/nvim-jdtls", -- Neovim java tools
            },
            config = function()
                require("mason").setup()
                local lspconf = require("lspconfig")
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
                            if client.name:match('omnisharp') then
                                print("Disabling Semantic Tokens on Omnisharp because Microsoft doesn't know how to read their own standards... RE: https://github.com/OmniSharp/omnisharp-roslyn/issues/2483")
                                client.server_capabilities.semanticTokensProvider = nil
                            end
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
                vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
                vim.fn.sign_define('DapBreakpointCondition', { text = '🔵', texthl = '', linehl = '', numhl = '' })
                require('dap.ext.vscode').load_launchjs()
                dapui.setup()
                dap.listeners.after.event_initialized['dapui_config'] = function()
                    dapui.open()
                end
                dap.listeners.before.event_terminated['dapui_config'] = function()
                    dapui.close()
                end
                dap.listeners.after.event_exited['dapui_config'] = function()
                    dapui.close()
                end
                local osv_port = 8086
                if not dap.launch_server then dap.launch_server = {} end
                dap.configurations.lua = {
                    {
                        type = 'nlua',
                        request = 'attach',
                        name = "Attach to running Neovim instance",
                    }
                }
                dap.configurations[''] = dap.configurations.lua
                dap.adapters.nlua = function(callback, config)
                    callback({ type = 'server', host = config.host or "127.0.0.1", port = config.port or osv_port })
                end
                dap.launch_server['nil'] = function()
                    print("Starting OSV DAP Server")
                    osv.launch({port = osv_port})
                end
            end,
        },
        {
            "theHamsta/nvim-dap-virtual-text", -- Neovim DAP Virutal Text lol what else do you think this is?'
            dependencies = {'nvim-treesitter/nvim-treesitter'},
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
                local expand_enter_mapping = function(fallback)
                    if not cmp.visible() or not cmp.get_active_entry() then
                        cmp.complete()
                        cmp.select_next_item()
                    elseif cmp.get_active_entry() then
                        confirm_mapping()
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
                        ["<C-Space>"] = cmp.mapping(expand_enter_mapping, {"i", "c"}),
                        ["<Enter>"] = confirm_mapping,
                        ["<Tab>"] = cmp.mapping({
                            i = confirm_mapping,
                            c = next_option_mapping,
                        }),
                        ["<Down>"] = cmp.mapping(next_option_mapping, { "i" }),
                        ["<Up>"] = cmp.mapping(previous_option_mapping, { "i" }),
                        ["<S-Tab>"] = cmp.mapping(previous_option_mapping, { "c" }),
                        ["<C-Up>"] = cmp.mapping(cmp.mapping.scroll_docs( -4)),
                        ["<C-Down>"] = cmp.mapping(cmp.mapping.scroll_docs(4)),
                    },
                    sources = cmp.config.sources({
                        { name = "nvim_lsp" },
                        { name = "plugins" },
                        { name = "luasnip",                option = { show_autosnippets = true } }, -- For luasnip users.
                        { name = "nvim_lsp_signature_help" },

                        { name = "dictionary",             keyword_length = 2 },
                        { name = "path" },
                        { name = "treesitter" }
                    }, {
                        { name = "buffer" },
                    }),
                })

                cmp.setup.cmdline("/", {
                    sources = {
                        { name = "buffer" },
                        { name = "treesitter" }
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
            dev = true,
            branch = "main",
            dependencies = {
                "nvim-lua/plenary.nvim",
                "kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
                "MunifTanjim/nui.nvim",
                "onsails/lspkind-nvim", -- Document Symbols
            },
            config = function()
                local lspkind = require("lspkind")
                vim.api.nvim_set_hl(0, "NeoTreeCursorLine", {bold=true, underline=true})
                local neo_tree = require("neo-tree")
                local config = {
                    popup_border_style = 'rounded',
                    source_selector = {
                        winbar = true,
                        sources = {
                            { source = "filesystem" },
                            { source = "buffers" },
                            { source = "document_symbols" },
                            { source = "remote" },
                        }
                    },
                    default_component_configs = {
                        name = {
                            highlight_opened_files = "all",
                        }
                    },
                    sources = {
                        "filesystem",
                        "buffers",
                        "document_symbols",
                        "netman.ui.neo-tree",
                    },
                    buffers = {
                        bind_to_cwd = false,
                    },
                    filesystem = {
                        filtered_items = {
                            visible = true,
                            hide_gitignored = false,
                            hide_hidden = false,
                            hide_dotfiles = false,
                        },
                        follow_current_file = {
                            enabled = true
                        },
                    },
                    log = {
                        level = "debug",
                    }
                }
                neo_tree.setup(config)
            end
            ,
        },
        {
            "miversen33/netman.nvim", -- Remove Resource Browser
            dev = true,
            branch = "v1.15",
            config = true
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
                highlight = "LspInlayHint",
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
            "Fildo7525/pretty_hover",
            event = "LspAttach",
            config = true,
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
        },
        {
            'nmac427/guess-indent.nvim',
            config = true
        },
        {
            'fedepujol/move.nvim',
            cmd = {
                'MoveLine',
                'MoveHChar',
                'MoveBlock',
                'MoveHBlock'
            }
        },
        {
            "Bekaboo/dropbar.nvim",
            opts = {
                icons = {
                    ui = {
                        bar = {
                            separator = "  "
                        }
                    }
                }
            }
        },
        {
            "nvim-treesitter",
            config = function()
                local ts_conf = require("nvim-treesitter.configs")
                ts_conf.setup({
                    auto_install = true
                })
            end
        },
        {
            "dnlhc/glance.nvim",
            config = true,
            opts = {
                height = 25,
                border = {
                    enable = true
                },
                list = {
                    position = "left"
                },
                theme = {
                    mode = "darken"
                }
            }
        },
        {
            "j-hui/fidget.nvim",
            tag = "legacy",
            event = "LspAttach",
            opts = {}
        },
        -- -- Scrollbars
        {
            "ggandor/leap.nvim",
            config = function()
                require("leap").add_default_mappings()
            end
        },
        {
            "lewis6991/gitsigns.nvim",
            config = true
        }
        -- Debugger
    }
    return plugins
end

local function setup_plugins()
    -- Currently using lazy, though we might use packer instead
    local plugins = get_plugins()
    require("lazy").setup(plugins, {
        dev = {
            path = "~/git",
            patterns = { "miversen33" },
            fallback = true
        },
        change_detection = {
            -- automatically check for config file changes and reload the ui
            enabled = true,
            notify = true, -- get a notification when changes are found
        },
    })
    require("custom_plugins") -- Load local plugins
end

bootstrap_package_manager()
setup_plugins()
