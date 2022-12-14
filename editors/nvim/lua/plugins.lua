-- Probably should assign some of these as lazy loading to help improve startup time?
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer = require("packer")
packer.reset()
packer.init()

local use = function(plugin, opts)
    opts = opts or {}
    local _ = vim.fn.glob(opts.dev)
    if opts.dev and _ and _:len() > 0 then
        -- Check to see if location exists. If so, use it
        plugin = opts.dev
        opts.dev = nil
    end
    opts[1] = plugin
    packer.use(opts)
end

use('wbthomason/packer.nvim') -- Neovim Use Packer

-- -- Debugger
use('mfussenegger/nvim-dap') -- Neovim Debug Adapter Protocol
use('rcarriga/nvim-dap-ui') -- Neovim DAP UI components. May not be necessary?
use('jbyuki/one-small-step-for-vimkind') -- Neovim plugin debugger
--
-- -- LSP Setup
use('ray-x/lsp_signature.nvim') -- Neovim lsp signature help
use('neovim/nvim-lspconfig') -- Neovim LSP Setup
-- use('williamboman/nvim-lsp-installer') -- Neovim LSP Installer
-- use('RRethy/vim-illuminate') -- Neovim highlight word under cursor
use('folke/lsp-colors.nvim') -- Neovim create missing lsp color highlight groups
use('folke/trouble.nvim') -- Neovim better diagnostics?
-- use('RishabhRD/nvim-lsputils')
use("https://git.sr.ht/~whynothugo/lsp_lines.nvim")
-- -- use('glepnir/lspsaga.nvim') -- Neovim LSP tools
-- -- use('jose-elias-alvarez/null-ls.nvim' -- Neovim "non lsp") lsp
--
-- -- Language Specific
-- use('sheerun/vim-polyglot') -- testing out some language specific packages?
-- -- use('gennaro-tedesco/nvim-jqx') -- Neovim JSON query tool
use('simrat39/rust-tools.nvim') -- Neovim Rust Tool
-- -- use {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', cmd = 'MarkdownPreview'} -- Neovim Markdown tool
-- use {'ellisonleao/glow.nvim', run = ':GlowInstall' } -- Neovim Markdown Preview in Neovim
use("folke/neodev.nvim")
use('mfussenegger/nvim-jdtls') -- Neovim jdtls extensions for java

-- -- Theme(s)
use("catppuccin/nvim", { as = "catppuccin" })
use('nvim-lualine/lualine.nvim') -- Neovim status line
use('kyazdani42/nvim-web-devicons') -- Devicons
use('noib3/nvim-cokeline') -- Neovim Tab/Buffer Bar. More customizable than barbar, potentially use this?
-- use('edluffy/specs.nvim') -- Neovim cursorline jump highlighter
use('onsails/lspkind-nvim') -- Neovim lsp pictograms
-- -- use('tomasr/molokai') -- Molokai Theme
-- -- use('karb94/neoscroll.nvim') -- Neovim Better Scrolling
-- -- use('SmiteshP/nvim-gps') -- Neovim status bar component for locating yourself within your code
-- -- use('folke/zen-mode.nvim' -- Neovim "zen" style coding where it hides everything except the pane you')re in. Not sold on it being actually useful though

-- -- IDE Specific
use('windwp/nvim-autopairs')
use('rafamadriz/friendly-snippets') -- Snippets boi
use('kevinhwang91/nvim-hlslens')
use('yamatsum/nvim-cursorline')
-- use('ojroques/vim-oscyank')
use('ojroques/nvim-osc52') -- Neovim clipboard integration
-- use('wakatime/vim-wakatime')
use('hrsh7th/nvim-cmp') -- Neovim autocompletion
use('rcarriga/cmp-dap') -- Neovim autocomplete for dap
use('L3MON4D3/LuaSnip') -- Neovim Lua based snippet manager
-- use('nvim-pack/nvim-spectre') -- Neovim Search and Replace
-- use('tpope/vim-fugitive') -- Vim Git Wrapper
use('saadparwaiz1/cmp_luasnip') -- Neovim LuaSnip autocompletion engine for nvim-cmp
use('hrsh7th/cmp-nvim-lsp') -- vim/neovim snippet stuffs
use('KadoBOT/cmp-plugins') -- Neovim plugin autocompletion
-- use('f3fora/cmp-spell') -- neovim spellcheck snippet stuffs
use('hrsh7th/cmp-buffer') -- vim/neovim snippet stuffs
use('hrsh7th/cmp-path') -- vim/neovim snippet stuffs
use('hrsh7th/cmp-cmdline') -- vim/neovim snippet stuffs
-- use('hrsh7th/cmp-calc') -- vim/neovim snippet stuffs
-- use('uga-rosa/cmp-dictionary') -- vim/neovim dictionary snippets? Maybe spellcheck without spellcheck?
-- use('hrsh7th/cmp-nvim-lua') -- vim/neovim lua api completion
-- -- use('kristijanhusak/vim-dadbod-completion') -- Vim Database Autocompletion
use('hrsh7th/cmp-nvim-lsp-signature-help')
use('ray-x/cmp-treesitter') -- Neovim snippet for treesitter (Maybe replace the buffer completion?)
use('nvim-telescope/telescope-file-browser.nvim') -- Neovim Telescope File Manager
-- -- use('nvim-telescope/telescope-project.nvim') -- Neovim Telescope Project Manager
-- -- use('cljoly/telescope-repo.nvim') -- Neovim Telescope Repository Project Manager
-- -- use('simrat39/symbols-outline.nvim') -- Neovim symbol viewer (use treesitter vs ctags)
-- use('tpope/vim-dadbod') -- Vim Database interaction
-- use('kristijanhusak/vim-dadbod-ui') -- Vim UI for database interaction
-- -- use('folke/which-key.nvim') -- Neovim keybinding help display
-- -- use('rcarriga/vim-ultest') -- Neovim unit testing your code?
-- -- use('gelguy/wilder.nvim') -- Neovim command autocomplete?
-- -- use('steelsojka/pears.nvim') -- Neovim auto pair
-- use('kevinhwang91/nvim-bqf') -- Neovim Better Quickfix
use('numToStr/Comment.nvim') -- Neovim Commenting
-- use('folke/todo-comments.nvim') -- Neovim TODO Comment Highlighting
-- -- use('f-person/git-blame.nvim') -- Neovim Git Blame (shows via virtual text)
-- -- use('rhysd/git-messenger.vim') -- Vim git blame in popup wi use 'rhysd/git-messenger.vim' -- Vim git blame in popup windowndow
-- -- use {'ms-jpq/chadtree', branch = 'chad', run = 'python3 -m chadtree deps'} -- Neovim File Explorer with no external dependencies. Doesn't appear to have ssh support
-- -- use {
-- --   'kyazdani42/nvim-tree.lua', -- Neovim File Explorer with no external dependencies. Does appear to have _some_ form of ssh support
-- --   requires = {
-- --     'kyazdani42/nvim-web-devicons', -- optional, for file icon
-- --   },
-- -- }
use('mg979/vim-visual-multi')
use('lukas-reineke/indent-blankline.nvim') -- Neovim indentation handling
use('tami5/sqlite.lua') -- Neovim SQlite database
use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' }) -- Neovim treesitter
use('nvim-telescope/telescope.nvim') -- Fuzzy Finder
use('nvim-telescope/telescope-fzf-native.nvim', { run = 'make' }) -- Fuzzy Finder with fzf-native
use('nvim-telescope/telescope-live-grep-args.nvim')
-- use('nvim-orgmode/orgmode')
use('uga-rosa/ccc.nvim') -- Neovim color picker?
-- -- use('ahmedkhalf/project.nvim') -- Neovim project management
-- -- use('gbprod/substitute.nvim') -- Neovim better substitution
-- -- use('filipdutescu/renamer.nvim') -- Neovim vscode style variable renaming
-- -- use('ethanholz/nvim-lastplace') -- Neovim open file in the last place you were (if the file has been opened before?)
use('rcarriga/nvim-notify') -- Neovim notifications?
-- use('romgrk/nvim-treesitter-context') -- Neovim code context

-- -- Utilies
use('SmiteshP/nvim-navic') -- Neovim location based symbol loader...?
use('lewis6991/gitsigns.nvim') -- Neovim Git Stuffs (Depending on how much git we want to use, we might want to go this route)
use('TimUntersberger/neogit', {
    requires = {
        'nvim-lua/plenary.nvim',
        'sindrets/diffview.nvim'
    }
})
use('kevinhwang91/nvim-ufo', { requires = 'kevinhwang91/promise-async' }) -- Better folding? Idk we will see
use('anuvyklack/hydra.nvim')
use('VonHeikemen/searchbox.nvim', { requires = 'MunifTanjim/nui.nvim' }) -- Puts a searchbox in the top right corner. I mean... Why not?
use('bennypowers/nvim-regexplainer', {
    requires = {
        'nvim-treesitter/nvim-treesitter',
        'MunifTanjim/nui.nvim'
    },
    run = ':TSInstall regex'
})
use('miversen33/netman.nvim', { dev = '~/git/netman.nvim', branch = "v1.1" })
use('hkupty/iron.nvim')
use('haringsrob/nvim_context_vt')
use('ziontee113/icon-picker.nvim', { requires = 'stevearc/dressing.nvim' }) -- Nerdfont picker
-- use('David-Kunz/markid')
-- -- use('monaqa/dial.nvim') -- Neovim better increment?
-- use('lewis6991/satellite.nvim') -- Scrollbar?
use('miversen33/import.nvim', { dev = "~/git/import.nvim" }) -- Local import function
use('nvim-neo-tree/neo-tree.nvim', {
    branch = "v2.x",
    requires = {
        "nvim-lua/plenary.nvim",
        "kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
    }
}) -- File Explorer
use('vimwiki/vimwiki')
use('nvim-lua/plenary.nvim') -- Neovim "Utility functions"
use('mrjones2014/smart-splits.nvim') -- Neovim better split handling?
use('stevearc/aerial.nvim') -- Better code outline??
-- -- Configure this so its "pretty"
-- -- use('voldikss/vim-floaterm') -- Vim/Neovim floating terminal
use('akinsho/toggleterm.nvim') -- Neovim Floating Terminal Framework
use('m-demare/hlargs.nvim', { requires = 'nvim-treesitter/nvim-treesitter' })
use('declancm/maximize.nvim')
-- -- use('aserowy/tmux.nvim') -- Neovim Tmux integration
-- -- use('numToStr/Navigator.nvim') -- Neovim better pane handling
--
-- -- We can almost certainly remove fzf...?
-- use('junegunn/fzf')
-- use('junegunn/fzf.vim')
-- Automatically set up your configuration after cloning packer.nvim
-- Put this at the end after all plugins
if ensure_packer() then
    packer.sync()
end
-- end)

require("import").config({output_split_type='vertical', import_enable_better_printing=true})
import('notify', function(notify)
    -- Overriding vim.notify with fancy notify if fancy notify exists
    vim.notify = notify
    notify.setup({})
end)
-- Plugin Configurations
local excluded_filetypes_array = {
    'lsp-installer',
    'lspinfo', 'Outline',
    'help',
    'packer',
    'netrw',
    'qf',
    'dbui',
    'Trouble',
    'fugitive',
    'floaterm',
    'spectre_panel',
    'spectre_panel_write',
    'checkhealth',
    'man',
    'dap-repl',
    'toggleterm',
    'neo-tree',
    'ImportManager',
    'aerial'
}
local excluded_filetypes_table = {}
for _, value in ipairs(excluded_filetypes_array) do
    excluded_filetypes_table[value] = 1
end
vim.g['db_ui_auto_execute_table_helpers'] = 1

import('lsp_lines', function(lsp_lines)
    lsp_lines.setup()
    vim.diagnostic.config({virtual_text=false})
end)

import('indent_blankline', function(indent_blankline)
    indent_blankline.setup({
        filetype_exclude = excluded_filetypes_array,
        show_current_context = true,
        show_current_context_start = true,
        use_treesitter = true,
    })
end)

import('Comment', function(comment) comment.setup() end)
import('custom_theme')
import({'lualine', 'nvim-navic', 'lspkind'}, function(modules)
    local lualine = modules.lualine
    local lspkind = modules.lspkind
    local nvim_navic = modules['nvim-navic']
    nvim_navic.setup({
        seperator = '',
        highlight = true,
    })
    local create_symbol_bar = function()
        if not nvim_navic.is_available() then
            return ''
        end
        local details = {}
        for _, item in ipairs(nvim_navic.get_data()) do
            table.insert(details, item.icon .. item.name)
        end
        return table.concat(details, ' > ')
    end
    local get_buf_filetype = function()
        return vim.api.nvim_buf_get_option(0, 'filetype')
    end
    local format_name = function(output)
        if excluded_filetypes_table[get_buf_filetype()] then return '' end
        return output
    end
    local branch_max_width = 40
    local branch_min_width = 10
    lualine.setup({
        options = {
            theme = 'catppuccin',
            disabled_filetypes = {
                winbar = excluded_filetypes_array
            },
            globalstatus = true
        },
        sections = {
            lualine_a = {
                'mode',
                {
                    'branch',
                    fmt = function(output)
                        local win_width = vim.o.columns
                        local max = branch_max_width
                        if win_width * .25 < max then max = math.floor(win_width * .25) end
                        if max < branch_min_width then max = branch_min_width end
                        if max % 2 ~= 0 then max = max + 1 end
                        if output:len() >= max then
                            return output:sub(1, (max / 2) - 1 ) .. '...' .. output:sub(-1 * ((max / 2) - 1), -1)
                        end
                        return output
                    end
                },
            },
            lualine_b = {
                {
                    'filename',
                    file_status = false,
                    path = 1,
                    fmt = format_name
                },
                {
                    'diagnostics',
                    update_in_insert = true
                },
            },
            lualine_c = {},
            lualine_x = {
                "import"
            },
            lualine_y = {
                {
                    'filetype',
                    icon_only = true
                },
                'encoding',
                'progress',
            },
            lualine_z = {
                'location'
            }
        },
        inactive_sections = {
            lualine_a = {
            },
            lualine_b = {
            },
            lualine_c = {
                {
                    'filetype',
                    icon_only = true
                },
                {
                    'filename',
                    path = 1,
                    fmt = format_name
                }
            },
            lualine_x = {

            },
            lualine_y = {

            },
            lualine_z = {

            }
        },
        winbar = {
            lualine_a = {
                {'filetype', icon_only = true, icon = { align = 'left'}},
                {'filename', file_status = false, path = 0},
            },
            lualine_b = {},
            lualine_c = { create_symbol_bar },
            lualine_x = {},
            lualine_y = {},
            lualine_z = {}
        },
        inactive_winbar = {
            lualine_a = {
                {'filetype', icon_only = true, icon = { align = 'left'}},
                {'filename', file_status = false, path = 0},
            },
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {}
        }
    })
end)

import('cokeline', function(cokeline)
    local get_hex = require("cokeline.utils").get_hex
    local active_bg_color = '#931E9E'
    local inactive_bg_color = get_hex('Normal', 'bg')
    local bg_color = get_hex('ColorColumn', 'bg')
    local no_error_color = '#3DEB63'
    local error_color = '#C95157'
    local warn_color = '#e1c400'
    import('catppuccin.palettes', function(cc)
        local pallet = cc.get_palette()
        active_bg_color = pallet.overlay1
        inactive_bg_color = pallet.base
        bg_color = pallet.base
        error_color = pallet.red
        no_error_color = pallet.green
        warn_color = pallet.yellow
    end)
    local setup = {
        show_if_buffers_are_at_least = 1,
        buffers = {
            filter_valid = function(buffer)
                if (excluded_filetypes_table[buffer.type] or excluded_filetypes_table[buffer.filetype]) then
                    return false
                end
                return true
            end
        },
        mappings = {
            cycle_prev_next = true
        },
        default_hl = {
            bg = function(buffer)
                if buffer.is_focused then
                    return active_bg_color
                end
            end,
        },
        components = {
            {
                text = function(buffer)
                    local _text = ''
                    if buffer.index > 1 then _text = ' ' end
                    if buffer.is_focused or buffer.is_first then
                        _text = _text .. ''
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
                end
            },
            {
                text = function(buffer)
                    local status = ''
                    if buffer.is_readonly then
                        status = ' ➖'
                    elseif buffer.is_modified then
                        status = ' '
                    end
                    return status
                end,
                fg = function(buffer)
                    if buffer.is_focused and
                        (
                        buffer.is_readonly
                            or buffer.is_modified
                        ) then
                        return warn_color
                    end
                end
            },
            {
                text = function(buffer)
                    return " " .. buffer.devicon.icon
                end,
                fg = function(buffer)
                    if buffer.is_focused then
                        return buffer.devicon.color
                    end
                end
            },
            {
                text = function(buffer)
                    return buffer.unique_prefix .. buffer.filename .. ' '
                end,
                fg = function(buffer)
                    if (buffer.diagnostics.errors > 0) then
                        return error_color
                    end
                end,
                style = function(buffer)
                    local text_style = 'NONE'
                    if buffer.is_focused then
                        text_style = 'bold'
                    end
                    if buffer.diagnostics.errors > 0 then
                        if text_style ~= 'NONE' then
                            text_style = text_style .. ',underline'
                        else
                            text_style = 'underline'
                        end
                    end
                    return text_style
                end
            },
            {
                text = function(buffer)
                    local errors = buffer.diagnostics.errors
                    if (errors <= 9) then
                        errors = ''
                    else
                        errors = "🙃"
                    end
                    return errors .. ' '
                end,
                fg = function(buffer)
                    if buffer.diagnostics.errors == 0 then
                        return no_error_color
                    elseif buffer.diagnostics.errors <= 9 then
                        return error_color
                    end
                end
            },
            {
                text = ' ',
                delete_buffer_on_left_click = true
            },
            {
                text = function(buffer)
                    if buffer.is_focused or buffer.is_last then
                        return ''
                    else
                        return ' '
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
                end
            }
        },
    }
    cokeline.setup(setup)
end)

-- Setup nvim-cmp
-- TODO: Setup these colors to match colors in catppuccin for theme matching

local CmpItemAbbrDeprecated = "#808080"
local CmpItemAbbrMatch = "#569CD6"
local CmpItemAbbrMatchFuzzy = "#569CD6"
local CmpItemKindVariable = "#9CDCFE"
local CmpItemKindInterface = "#9CDCFE"
local CmpItemKindText = "#9CDCFE"
local CmpItemKindFunction = "#C586C0"
local CmpItemKindMethod = "#C586C0"
local CmpItemKindKeyword = "#D4D4D4"
local CmpItemKindProperty = "#D4D4D4"
local CmpItemKindUnit = "#D4D4D4"
local TreesitterContext = "#2D336E"

import('catppuccin.palettes', function(cc)
    local pallet = cc.get_palette()

    CmpItemAbbrDeprecated = pallet.overlay0
    CmpItemAbbrMatch = pallet.sapphhire
    CmpItemAbbrMatchFuzzy = pallet.sapphire
    CmpItemKindVariable = pallet.teal
    CmpItemKindInterface = pallet.teal
    CmpItemKindText = pallet.teal
    CmpItemKindFunction = pallet.red
    CmpItemKindMethod = pallet.red
    CmpItemKindKeyword = pallet.rosewater
    CmpItemKindProperty = pallet.rosewater
    CmpItemKindUnit = pallet.rosewater
    TreesitterContext = pallet.surface0

end)

vim.cmd(string.format("highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=%s", CmpItemAbbrDeprecated))
vim.cmd(string.format("highlight! CmpItemAbbrMatch guibg=NONE guifg=%s", CmpItemAbbrMatch))
vim.cmd(string.format("highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=%s", CmpItemAbbrMatchFuzzy))
vim.cmd(string.format("highlight! CmpItemKindVariable guibg=NONE guifg=%s", CmpItemKindVariable))
vim.cmd(string.format("highlight! CmpItemKindInterface guibg=NONE guifg=%s", CmpItemKindInterface))
vim.cmd(string.format("highlight! CmpItemKindText guibg=NONE guifg=%s", CmpItemKindText))
vim.cmd(string.format("highlight! CmpItemKindFunction guibg=NONE guifg=%s", CmpItemKindFunction))
vim.cmd(string.format("highlight! CmpItemKindMethod guibg=NONE guifg=%s", CmpItemKindMethod))
vim.cmd(string.format("highlight! CmpItemKindKeyword guibg=NONE guifg=%s", CmpItemKindKeyword))
vim.cmd(string.format("highlight! CmpItemKindProperty guibg=NONE guifg=%s", CmpItemKindProperty))
vim.cmd(string.format("highlight! CmpItemKindUnit guibg=NONE guifg=%s", CmpItemKindUnit))
vim.cmd(string.format("highlight! TreesitterContext guibg=%s gui=bold", TreesitterContext))

import({'cmp', 'luasnip', 'lspkind', 'cmp_dap', 'cmp-plugins', 'nvim-autopairs'},  function(modules)
    local cmp            = modules.cmp
    local luasnip        = modules.luasnip
    local lspkind        = modules.lspkind
    local cmp_dap        = modules.cmp_dap
    local cmp_plugins    = modules['cmp-plugins']
    local nvim_autopairs = modules['nvim-autopairs']
    local cmp_autopairs  = require("nvim-autopairs.completion.cmp")
    nvim_autopairs.setup({
        disabled_filetypes = excluded_filetypes_array
    })
    cmp_plugins.setup({files = { ".*\\.lua"}})
    luasnip.config.set_config({ history = true, update_events = 'TextChanged,TextChangedI'})
    require("luasnip.loaders.from_vscode").lazy_load()
    local confirm_mapping = function(fallback)
        if luasnip.expandable() then
            return luasnip.expand()
        end
        if cmp and cmp.visible() and cmp.get_active_entry() then
            cmp.confirm({
                behavior = cmp.ConfirmBehavior.Replace,
                select = false
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
            return vim.api.nvim_buf_get_option(0, 'buftype') ~= 'prompt' or cmp_dap.is_dap_buffer()
        end,
        formatting = {
            format = lspkind.cmp_format()
        },
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body) -- For `luasnip` users.
            end,
        },
        mapping = {
            ['<Enter>'] = confirm_mapping,
            ['<Tab>']   = cmp.mapping({
                i = confirm_mapping,
                c = next_option_mapping
            }),
            ['<Down>']  = cmp.mapping(next_option_mapping, {'i'}),
            ['<Up>']    = cmp.mapping(previous_option_mapping, {'i'}),
            ['<S-Tab>'] = cmp.mapping(previous_option_mapping, {'c'}),
            ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), {'i', 'c'}),
            ['<C-Up>']    = cmp.mapping(cmp.mapping.scroll_docs(-4)),
            ['<C-Down>']  = cmp.mapping(cmp.mapping.scroll_docs(4)),
            ['<Esc>'] = cmp.mapping({
                i = cmp.abort(),
                c = cmp.close(),
            })
        },
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'plugins' },
            { name = 'luasnip', option = { show_autosnippets = true } }, -- For luasnip users.
            { name = 'nvim_lsp_signature_help' },

            { name = 'dictionary', keyword_length = 2 },
            { name = 'path' },
            -- { name = "treesitter" }
        }, {
            { name = 'buffer' },
        })
    })

    cmp.setup.cmdline('/', {
        sources = {
            { name = 'buffer' }
        }
    })

    cmp.setup.cmdline(':', {
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
            { name = 'cmdline' }
        })
    })
    cmp.setup.filetype({'dap-repl', 'dapui_watches', 'dapui_hover'}, {
        sources = { name = 'dap'}
    })
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
end)

import('telescope', function(telescope)
    local t_actions = nil
    import('telescope.actions', function(_) t_actions = _ end)
    assert(t_actions)
    telescope.setup({
        pickers = {
            colorscheme = {
                enable_preview = true,
            }
        },
        defaults = {
            mappings = {
                n = {
                    ["<C-Up>"] = t_actions.preview_scrolling_up,
                    ["<C-Down>"] = t_actions.preview_scrolling_down
                },
                i = {
                    ["<C-Up>"] = t_actions.preview_scrolling_up,
                    ["<C-Down>"] = t_actions.preview_scrolling_down
                }
            },
            layout_strategy = "vertical"
        },
        extensions = {
            file_browser = {
                grouped           = true,
                hidden            = true,
                respect_gitignore = false,
            }
        },
    })
    telescope.load_extension('fzf')
    telescope.load_extension('live_grep_args')
    telescope.load_extension('file_browser')
end)

import('trouble', function(trouble) trouble.setup({
        icons = true
    })
end)


-- import('todo-comments', function(todo_comments) todo_comments.setup({
--
--     })
-- end)

-- DAP Setup
import({'dap', 'dapui'}, function(modules)
    local dap = modules.dap
    local dapui = modules.dapui
    if not dap.launch_server then dap.launch_server = {} end
    vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
    vim.fn.sign_define('DapBreakpointCondition', { text = '🔵', texthl = '', linehl = '', numhl = '' })
    require('dap.ext.vscode').load_launchjs()
    dapui.setup({})
    dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
    end
    dap.listeners.after.event_exited['dapui_config'] = function()
        dapui.close()
    end
    import({'dap', 'osv'}, function(_modules)
        local _dap = _modules.dap
        local _osv = _modules.osv
        local port = 8086
        local output = vim.fn.system(string.format('netstat -tlupn | grep %s', port))
        _dap.configurations.lua = {
            {
                type = 'nlua',
                request = 'attach',
                name = "Attach to running Neovim instance",
            }
        }
        _dap.adapters.nlua = function(callback, config)
            callback({ type = 'server', host = config.host or "127.0.0.1", port = config.port or port })
        end
        _dap.launch_server['nil'] = function()
            if output:match(string.format('%s', port)) then
                print("There is already a process running on port 8086")
                -- Found free port
                return
            end
            print("Starting OSV DAP Server")
            _osv.launch({port = port, log = true})
        end
    end)
end)

import('netman')
import('aerial', function(aerial) aerial.setup({
        ignore = { filetypes = excluded_filetypes_array },
        backends = { 'treesitter', 'lsp', 'markdown', 'man' },
        filter_kind = {
            "Class",
            "Constructor",
            "Enum",
            "Function",
            "Interface",
            "Module",
            "Method",
            "Struct",
            "Variable"
        },
        layout = {
            placement = "edge"
        },
        lazy_mode = false,
        update_events = "TextChanged,InsertLeave,WinEnter,WinLeave",
        show_guides = true,
        attach_mode = "global",
    })
end)

-- Tree-sitter configuration
import({'nvim-treesitter.configs', 'nvim-treesitter.highlight'}, function(modules)
  modules['nvim-treesitter.configs'].setup({
    -- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
    highlight = { enable = true },
    markid = { enable = true}
  })
  -- modules['nvim-treesitter.highlight'].set_custom_captures({
  --   ["hlargs.namedparam"] = "Hlargs",
  -- })
end)


import('toggleterm', function(toggleterm) toggleterm.setup({}) end)
import('icon-picker')
import('ccc', function(ccc)
    ccc.setup({
        highlighter = {
            auto_enable = true
        },
        bar_char = "█"
    })
end)

import('neo-tree', function(neo_tree)
    neo_tree.setup({
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
            follow_current_file = true
        }
        -- }
    })
end)

import("osc52", function(osc52)
    osc52.setup({
        max_length = 0,
        silent = false,
        trim = false,
    })

    local function copy(lines, _)
        osc52.copy(table.concat(lines, '\n'))
    end

    local function paste()
        return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') }
    end

    vim.keymap.set('n', '<leader>c', osc52.copy_operator, { expr = true })
    vim.keymap.set('n', '<leader>cc', '<leader>c_', { remap = true })
    vim.keymap.set('x', '<leader>c', osc52.copy_visual)

    vim.g.clipboard = {
        name = 'osc52',
        copy = {
            ['+'] = copy,
            ['*'] = copy
        },
        paste = {
            ['+'] = paste,
            ['*'] = paste
        },
    }
end)

import('hlslens', function(hlslens)
    local kopts = { noremap = true, silent = true }
    vim.api.nvim_set_keymap('n', 'n',
        [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
        kopts)
    vim.api.nvim_set_keymap('n', 'N',
        [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
        kopts)
    vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
    vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
    vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
    vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

    vim.api.nvim_set_keymap('n', '<Leader>l', ':noh<CR>', kopts)

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
    vim.cmd([[
        aug VMlens
            au!
            au User visual_multi_start lua require('vmlens').start()
            au User visual_multi_exit lua require('vmlens').exit()
        aug END
    ]])
end)

import('nvim_context_vt', function(nvim_context_vt)
    nvim_context_vt.setup()
end)

import('nvim-cursorline', function(nvim_cursorline)
    -- See if you can hook this to make "n" go to the next occurance of the letter
    nvim_cursorline.setup()
end)

import('regexplainer', function(regexplainer)
    regexplainer.setup()
end)

import('hlargs', function(hlargs) hlargs.setup() end)

import('iron.core', function(iron)
    iron.setup({
        config = {
            scratch_rep = true,
            repl_definition = {
                lua = {
                    command = { "croissant" }
                },
                python = {
                    command = { "/usr/bin/env", "python3" }
                }
            },
            repl_open_cmd = require("iron.view").split.vertical("30%")
        },
        keymaps = {
            send_motion = "<space>sc",
            visual_send = "<space>sc",
            send_file = "<space>sf",
            send_line = "<space>sl",
            send_mark = "<space>sm",
            mark_motion = "<space>mc",
            mark_visual = "<space>mc",
            remove_mark = "<space>md",
            cr = "<space>s<cr>",
            interrupt = "<space>s<space>",
            exit = "<space>sq",
            clear = "<space>cl",
        },
        -- If the highlight is on, you can change how it looks
        -- For the available options, check nvim_set_hl
        highlight = {
            italic = true
        }
    })
end)

import('smart-splits', function(smart_splits)
    smart_splits.setup({
        tmux_integration = false,
    })
end)

import('maximize', function(maximize) maximize.setup() end)
import('searchbox', function(searchbox)
    searchbox.setup({
        popup = {
            position = {
                row = "1%",
                col = "99%"
            },
        },
        defaults = {
            modifier = "disabled",
            clear_matches = true,
            show_matches = true
        }
    })
end)
import('lsp-colors', function(lsp_colors)
    lsp_colors.setup()
end)

import('ufo', function(ufo)
    vim.o.foldcolumn = '1'
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ('  %d '):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
            local chunkText = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
                table.insert(newVirtText, chunk)
            else
                chunkText = truncate(chunkText, targetWidth - curWidth)
                local hlGroup = chunk[2]
                table.insert(newVirtText, { chunkText, hlGroup })
                chunkWidth = vim.fn.strdisplaywidth(chunkText)
                -- str width returned from truncate() may less than 2nd argument, need padding
                if curWidth + chunkWidth < targetWidth then
                    suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                end
                break
            end
            curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
    end

    ufo.setup({
        provider_selector = function()
            return { 'treesitter', 'indent' }
        end,
        fold_virt_text_handler = handler
    })
    ufo.setFoldVirtTextHandler(vim.api.nvim_get_current_buf(), handler)
end)

import('neogit', function(neogit)
    neogit.setup()
end)

--- Custom shits below

import('custom_plugins', nil, { hide_output = true })
