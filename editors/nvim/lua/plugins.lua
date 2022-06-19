vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Neovim Use Packer

  -- Debugger
  use 'mfussenegger/nvim-dap' -- Neovim Debug Adapter Protocol
  use 'rcarriga/nvim-dap-ui' -- Neovim DAP UI components. May not be necessary?
  use 'jbyuki/one-small-step-for-vimkind' -- Neovim plugin debugger

  -- LSP Setup
  use 'neovim/nvim-lspconfig' -- Neovim LSP Setup
  use 'williamboman/nvim-lsp-installer' -- Neovim LSP Installer
  use 'RRethy/vim-illuminate' -- Neovim highlight word under cursor
  use 'folke/lsp-colors.nvim' -- Neovim create missing lsp color highlight groups
  use 'folke/trouble.nvim' -- Neovim better diagnostics?
  use 'RishabhRD/nvim-lsputils'
  -- use 'glepnir/lspsaga.nvim' -- Neovim LSP tools
  -- use 'jose-elias-alvarez/null-ls.nvim' -- Neovim "non lsp" lsp

  -- Language Specific
  use 'sheerun/vim-polyglot' -- testing out some language specific packages?
  -- use 'gennaro-tedesco/nvim-jqx' -- Neovim JSON query tool
  use 'simrat39/rust-tools.nvim' -- Neovim Rust Tool
  -- use {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', cmd = 'MarkdownPreview'} -- Neovim Markdown tool
  use {'ellisonleao/glow.nvim', run = ':GlowInstall' } -- Neovim Markdown Preview in Neovim
  -- Theme(s)
  use 'olimorris/onedarkpro.nvim' -- (onedark, onelight) Another onedark for Neovim
  use 'tanvirtin/monokai.nvim' -- (monokai, monokai_pro, monokai_soda) Monokai Theme
  use 'Mofiqul/vscode.nvim' -- (vscode: vscode_style=dark, light) VSCode Dark Theme (Treesitter supported)
  use 'kristijanhusak/vim-hybrid-material' -- (hybrid_material, hybrid_reverse) Dark Material Theme
  use 'rafamadriz/neon' -- (neon: neon_style: default, doom, dark, light) Neon Theme (Treesitter supported)
  use 'marko-cerovac/material.nvim' -- (material: material_style=darker, lighter, oceanic, palenight, deep ocean) Neovim Material Theme (Treesitter supported)
  use 'folke/tokyonight.nvim' -- (tokyonight: tokyonight_style= day, night, storm) Neovim dark theme
  use 'sainnhe/sonokai' -- (sonokai: sonokai_style= atlantis, andromeda, shusia, maia, espresso) High Contract Theme
  use 'projekt0n/github-nvim-theme' -- (github_dark, github_dark_default, github_dimmed, github_light, github_light_default)
  use 'nvim-lualine/lualine.nvim' -- Neovim status line
  use 'kyazdani42/nvim-web-devicons' -- Devicons
  -- is the route we want to go
  use 'noib3/nvim-cokeline' -- Neovim Tab/Buffer Bar. More customizable than barbar, potentially use this?
  -- use 'navarasu/onedark.nvim' -- (onedark: onedark_style=darker, cool, deep, warm, warmer) 
  use 'edluffy/specs.nvim' -- Neovim cursorline jump highlighter
  use 'onsails/lspkind-nvim' -- Neovim lsp pictograms
  -- use 'tomasr/molokai' -- Molokai Theme
  -- use 'karb94/neoscroll.nvim' -- Neovim Better Scrolling
  -- use 'SmiteshP/nvim-gps' -- Neovim status bar component for locating yourself within your code
  -- use 'folke/zen-mode.nvim' -- Neovim "zen" style coding where it hides everything except the pane you're in. Not sold on it being actually useful though

  -- IDE Specific
  use 'ojroques/vim-oscyank'
  use 'wakatime/vim-wakatime'
  use {
    'hrsh7th/nvim-cmp', -- Neovim autocompletion
    -- config = function() require('config.cmp') end,
  }
  use {
    'L3MON4D3/LuaSnip', -- Neovim Lua based snippet manager
    -- config = function() require('config.snippets') end,
  }
  use 'nvim-pack/nvim-spectre' -- Neovim Search and Replace
  use 'tpope/vim-fugitive' -- Vim Git Wrapper
  use 'saadparwaiz1/cmp_luasnip' -- Neovim LuaSnip autocompletion engine for nvim-cmp
  -- use 'hrsh7th/cmp-vsnip' -- Neovim autocompletion -> Neovim Snippet (vsnip) feeder
  -- use 'hrsh7th/vim-vsnip' -- Vim snippet manager
  use 'hrsh7th/cmp-nvim-lsp'  -- vim/neovim snippet stuffs
  use 'f3fora/cmp-spell' -- neovim spellcheck snippet stuffs
  use 'hrsh7th/cmp-buffer'  -- vim/neovim snippet stuffs
  use 'hrsh7th/cmp-path'  -- vim/neovim snippet stuffs
  use 'hrsh7th/cmp-cmdline'  -- vim/neovim snippet stuffs
  use 'hrsh7th/cmp-calc' -- vim/neovim snippet stuffs
  use 'uga-rosa/cmp-dictionary' -- vim/neovim dictionary snippets? Maybe spellcheck without spellcheck?
  use 'hrsh7th/cmp-nvim-lua' -- vim/neovim lua api completion
  -- use 'kristijanhusak/vim-dadbod-completion' -- Vim Database Autocompletion
  use 'ray-x/cmp-treesitter' -- Neovim snippet for treesitter (Maybe replace the buffer completion?)
  use 'nvim-telescope/telescope-file-browser.nvim' -- Neovim Telescope File Manager
  -- use 'nvim-telescope/telescope-project.nvim' -- Neovim Telescope Project Manager
  -- use 'cljoly/telescope-repo.nvim' -- Neovim Telescope Repository Project Manager 
  -- use 'simrat39/symbols-outline.nvim' -- Neovim symbol viewer (use treesitter vs ctags)
  use 'tpope/vim-dadbod' -- Vim Database interaction
  use 'kristijanhusak/vim-dadbod-ui' -- Vim UI for database interaction
  -- use 'folke/which-key.nvim' -- Neovim keybinding help display
  -- use 'rcarriga/vim-ultest' -- Neovim unit testing your code?
  -- use 'gelguy/wilder.nvim' -- Neovim command autocomplete?
  -- use 'steelsojka/pears.nvim' -- Neovim auto pair
  use 'kevinhwang91/nvim-bqf' -- Neovim Better Quickfix
  -- use 'rmagatti/auto-session' -- Neovim session management
  use 'numToStr/Comment.nvim' -- Neovim Commenting
  use 'folke/todo-comments.nvim' -- Neovim TODO Comment Highlighting
  -- use 'f-person/git-blame.nvim' -- Neovim Git Blame (shows via virtual text)
  -- use 'rhysd/git-messenger.vim' -- Vim git blame in popup wi use 'rhysd/git-messenger.vim' -- Vim git blame in popup windowndow
  -- use 'lewis6991/gitsigns.nvim' -- Neovim Git Stuffs (Depending on how much git we want to use, we might want to go this route)
  -- use {'ms-jpq/chadtree', branch = 'chad', run = 'python3 -m chadtree deps'} -- Neovim File Explorer with no external dependencies. Doesn't appear to have ssh support
  -- use {
  --   'kyazdani42/nvim-tree.lua', -- Neovim File Explorer with no external dependencies. Does appear to have _some_ form of ssh support 
  --   requires = {
  --     'kyazdani42/nvim-web-devicons', -- optional, for file icon
  --   },
  -- }
  use 'mg979/vim-visual-multi'
  use 'lukas-reineke/indent-blankline.nvim' -- Neovim indentation handling
  use 'tami5/sqlite.lua' -- Neovim SQlite database
  use {
    'nvim-treesitter/nvim-treesitter', -- Neovim Treesitter setup
    run = ':TSUpdate'
  }
  use 'nvim-telescope/telescope.nvim' -- Fuzzy Finder
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' } -- Fuzzy Finder with fzf-native
  use 'nvim-telescope/telescope-live-grep-args.nvim'
  -- use 'sunjon/Shade.nvim' -- Neovim inactive window dimmer (this is a nice plugin but it breaks _way_ too often...)
  use 'nvim-orgmode/orgmode'
  use 'norcalli/nvim-colorizer.lua' -- Neovim color highlighter
  -- use 'ahmedkhalf/project.nvim' -- Neovim project management
  -- use 'gbprod/substitute.nvim' -- Neovim better substitution
  -- use 'filipdutescu/renamer.nvim' -- Neovim vscode style variable renaming
  -- use 'ethanholz/nvim-lastplace' -- Neovim open file in the last place you were (if the file has been opened before?)
  -- use 'abecodes/tabout.nvim' -- Neovim tab escape parens?
  use 'rcarriga/nvim-notify' -- Neovim notifications?
  use 'romgrk/nvim-treesitter-context' -- Neovim code context
  -- use 'chipsenkbeil/distant.nvim' -- Neovim remote file editing (Note: Dependency https://github.com/chipsenkbeil/distant)
  -- use 'AckslD/nvim-neoclip.lua' -- Neovim Clipboard/register manager

  -- Utilies
  use 'miversen33/netman.nvim'
  use 'miversen33/import.nvim' -- Local import function
  use 'nvim-lua/plenary.nvim' -- Neovim "Utility functions"
  use 'mrjones2014/smart-splits.nvim' -- Neovim better split handling?
  use 'stevearc/aerial.nvim' -- Better code outline??
  -- Configure this so its "pretty"
  -- use 'voldikss/vim-floaterm' -- Vim/Neovim floating terminal
  use 'akinsho/toggleterm.nvim' -- Neovim Floating Terminal Framework
  use 'm-demare/hlargs.nvim'
  -- use 'aserowy/tmux.nvim' -- Neovim Tmux integration
  -- use 'numToStr/Navigator.nvim' -- Neovim better pane handling

  use 'junegunn/fzf'
  use 'junegunn/fzf.vim'
  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
      require('packer').sync()
  end
end)

require("import").config({output_split_type='vertical', import_enable_better_printing=true})

-- Plugin Configurations
local excluded_filetypes_array = {'lsp-installer', 'lspinfo', 'Outline', 'help', 'packer', 'netrw', 'qf', 'dbui', 'Trouble', 'fugitive', 'floaterm', 'spectre_panel', 'spectre_panel_write', 'checkhealth', 'man'}
local excluded_filetypes_table = {}
for _, value in ipairs(excluded_filetypes_array) do
    excluded_filetypes_table[value] = 1
end
vim.g['db_ui_auto_execute_table_helpers'] = 1

import('indent_blankline', function(indent_blankline)
  indent_blankline.setup({
      filetype_exclude = excluded_filetypes_array,
      show_current_context = true,
      show_current_context_start = true,
      use_treesitter = true,
  })
end)

-- vim.g['gitblame_display_virtual_text'] = 0

import('Comment', function(comment) comment.setup() end)
import('custom_theme')
import('lualine', function(lualine) lualine.setup{
  options = {
    theme = 'onedark',
    disabled_filetypes = excluded_filetypes_array,
    globalstatus = true
  },
  extensions = {'quickfix', 'fzf'},
  sections = {
    lualine_a = {
      'mode','branch', 
    },
    lualine_b = {
      {
        'filename',
        symbols = {
          modified = '',
          readonly = '',
          unamed = ''
        },
        path = 1
      }
      -- 'diff',
    },
    lualine_c = {
      {
        'diagnostics',
        update_in_insert = true
      }
    },
    lualine_x = {
        "aerial", {
          'filetype',
          icon_only = true
        }, {
          function()
            local failed_imports = require("import").get_failure_count()
            if failed_imports > 0 then
              return failed_imports .. " ⛔"
            else
              return ''
            end
          end
        }
    },
    lualine_y = {
      'encoding', 'progress',
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
          path = 1
      }
    },
    lualine_x = {
    
    },
    lualine_y = {
      
    },
    lualine_z = {

    }
  }
} end)

import('cokeline', function(cokeline)
    local get_hex = require("cokeline.utils").get_hex
    local active_bg_color = '#931E9E'
    local inactive_bg_color = get_hex('Normal', 'bg')
    local bg_color = get_hex('ColorColumn', 'bg')
    cokeline.setup({
      show_if_buffers_are_at_least = 1,
      buffers = {
          filter_valid = function(buffer)
              if(excluded_filetypes_table[buffer.type] or excluded_filetypes_table[buffer.filetype]) then
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
                      status = '➖'
                  elseif buffer.is_modified then
                      status = ''
                  end
                  return status
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
              end
          },
          {
              text = function(buffer)
                return buffer.unique_prefix .. buffer.filename
              end,
              fg = function(buffer)
                  if(buffer.diagnostics.errors > 0) then
                      return '#C95157'
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
                  if(errors <= 9) then
                      errors = ''
                  else
                      errors = "🙃"
                  end
                  return errors .. ' '
              end,
              fg = function(buffer)
                if buffer.diagnostics.errors == 0 then
                  return '#3DEB63'
                elseif buffer.diagnostics.errors <= 9 then
                  return '#DB121B'
                end
              end
          },
          {
              text = '',
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
  })
end)
import('specs', function(specs) specs.setup({
  show_jumps  = true,
  min_jump = 30,
  popup = {
      delay_ms = 0, -- delay before popup displays
      inc_ms = 5, -- time increments used for fade/resize effects 
      blend = 10, -- starting blend, between 0-100 (fully transparent), see :h winblend
      width = 70,
      winhl = "PMenu",
      fader = require('specs').pulse_fader,
      resizer = require('specs').shrink_resizer
  },
  ignore_filetypes = {},
  ignore_buftypes = {
      nofile = true,
  },
}) end)

-- Setup nvim-cmp
vim.cmd([[
highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6
highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6
highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE
highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE
highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0
highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4
highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4
highlight! TreesitterContext guibg=#2D336E gui=bold
]])
local kind_icons = {
  Text = "",
  Method = "",
  Function = "",
  Constructor = "",
  Field = "",
  Variable = "",
  Class = "ﴯ",
  Interface = "",
  Module = "",
  Property = "ﰠ",
  Unit = "",
  Value = "",
  Enum = "",
  Keyword = "",
  Snippet = "",
  Color = "",
  File = "",
  Reference = "",
  Folder = "",
  EnumMember = "",
  Constant = "",
  Struct = "",
  Event = "",
  Operator = "",
  TypeParameter = ""
}


import('cmp', function(cmp)
    local luasnip = nil
    local lspkind = nil
    import('luasnip', function(_) luasnip = _ end)
    import("lspkind", function(_) lspkind = _ end)
    assert(luasnip)
    assert(lspkind)
    cmp.setup({

  formatting = {
    format = function(entry, vim_item)
      vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
      vim_item.menu = ({
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        luasnip = "[LuaSnip]",
        nvim_lua = "[Lua]",
        latex_symbols = "[LaTeX]",
      })[entry.source_name]
      return vim_item
    end
    -- lspkind.cmp_format(),
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = {
    ['<Up>'] = cmp.mapping(cmp.mapping.select_prev_item(), {'i', 'c'}),
    ['<Down>'] = cmp.mapping(cmp.mapping.select_next_item(), {'i', 'c'}),
    ['<Enter>'] = cmp.mapping(cmp.mapping.confirm({select=true}), {'i'}),
    -- ['<Space>'] = cmp.mapping(cmp.mapping.confirm({select=true}), {'i'}),
    ['<Tab>'] = cmp.mapping(cmp.mapping.confirm({select=true}), {'i'}),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-Up>'] = cmp.mapping(cmp.mapping.scroll_docs(-4)),
    ['<C-Down>'] = cmp.mapping(cmp.mapping.scroll_docs(4)),
    ['<Esc>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
    })
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' }, -- For luasnip users.
    { name = 'orgmode' },
    { name = 'calc' },
    { name = 'dictionary', keyword_length=2 },
    { name = 'path' },
    { name = "nvim_lua" }
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
end)

import("cmp_dictionary", function(cmp_dictionary) cmp_dictionary.setup({dic = {["*"] = {"/usr/share/dict/words"}}, first_case_insensitive=true}) end)

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
                grouped = true,
                hidden  = true
            }
        },
    })
    telescope.load_extension('fzf')
    telescope.load_extension('live_grep_args')
    telescope.load_extension('file_browser')
end)

import('trouble', function(trouble) trouble.setup({
  use_diagnostic_signs = true
}) end)

-- Maybe a better solution here?
import('treesitter-context', function(treesitter_context) treesitter_context.setup({
    -- throttle = false,
    max_lines = 3,
    patters = {
        default = {
            'class',
            'function',
            'method',
            'for',
            'while',
            'if',
            'switch',
            'case'
        }
    }
}) end)

import('bqf', function(bqf) bqf.setup({

}) end)

import('todo-comments', function(todo_comments) todo_comments.setup({

}) end)

-- DAP Setup
import('dap', function(dap)
    vim.fn.sign_define('DapBreakpoint', {text='🔴', texthl='', linehl='', numhl=''})
    vim.fn.sign_define('DapBreakpointCondition', {text='🔵', texthl='', linehl='', numhl=''})
    require('dap.ext.vscode').load_launchjs()
    local dapui = require("dapui")
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
end)

import('spectre', function(spectre) spectre.setup({}) end)
import('smart-splits', function(smart_splits) smart_splits.ignored_buftypes=excluded_filetypes_array end)
import('netman')
import('aerial', function(aerial) aerial.setup({
    ignore = { filetypes = excluded_filetypes_array },
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
    placement_editor_edge = true,
    update_events = "TextChanged,InsertLeave,WinEnter,WinLeave",
    show_guides = true,
    close_behavior = "global"
}) end)

import('orgmode', function(orgmode) orgmode.setup_ts_grammar() end)

-- Tree-sitter configuration
import('nvim-treesitter.configs', function(nvim_treesitter_configs) nvim_treesitter_configs.setup({
  -- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
  highlight = {
    enable = true,
    disable = {'org'}, -- Remove this to use TS highlighter for some of the highlights (Experimental)
    additional_vim_regex_highlighting = {'org'}, -- Required since TS highlighter doesn't support all syntax features (conceal)
  },
  ensure_installed = {'org'}, -- Or run :TSUpdate org
}) end)

import('orgmode', function(orgmode) orgmode.setup({}) end)
import('hlargs', function(hlargs) hlargs.setup() end)
import('toggleterm', function(toggleterm) toggleterm.setup({}) end)
