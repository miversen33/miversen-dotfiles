vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Neovim Use Packer 

  -- Debugger 
  use 'mfussenegger/nvim-dap' -- Neovim Debug Adapter Protocol
  -- use 'rcarriga/nvim-dap-ui' -- Neovim DAP UI components. May not be necessary?
  
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
  -- use 'gennaro-tedesco/nvim-jqx' -- Neovim JSON query tool

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
  -- use 'romgrk/barbar.nvim' -- Neovim Tab/Buffer Bar -- Use this until we get cokeline setup. Cokeline 
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
  use {
    'hrsh7th/nvim-cmp', -- Neovim autocompletion
    -- config = function() require('config.cmp') end,
  }
  use {
    'L3MON4D3/LuaSnip', -- Neovim Lua based snippet manager
    -- config = function() require('config.snippets') end,
  }
  use 'saadparwaiz1/cmp_luasnip' -- Neovim LuaSnip autocompletion engine for nvim-cmp
  -- use 'hrsh7th/cmp-vsnip' -- Neovim autocompletion -> Neovim Snippet (vsnip) feeder
  -- use 'hrsh7th/vim-vsnip' -- Vim snippet manager
  use 'hrsh7th/cmp-nvim-lsp'  -- vim/neovim snippet stuffs
  use 'hrsh7th/cmp-buffer'  -- vim/neovim snippet stuffs
  use 'hrsh7th/cmp-path'  -- vim/neovim snippet stuffs
  use 'hrsh7th/cmp-cmdline'  -- vim/neovim snippet stuffs
  -- use 'kristijanhusak/vim-dadbod-completion' -- Vim Database Autocompletion
  use 'ray-x/cmp-treesitter' -- Neovim snippet for treesitter (Maybe replace the buffer completion?)
  use 'liuchengxu/vista.vim' -- Vim symbol viewer (uses ctags vs treesitter)
  -- use 'simrat39/symbols-outline.nvim' -- Neovim symbol viewer (use treesitter vs ctags)
  -- use 'tpope/vim-dadbod' -- Vim Database interaction
  -- use 'kristijanhusak/vim-dadbod-ui' -- Vim UI for database interaction
  -- use 'folke/which-key.nvim' -- Neovim keybinding help display
  -- use 'rcarriga/vim-ultest' -- Neovim unit testing your code?
  -- use 'gelguy/wilder.nvim' -- Neovim command autocomplete?
  -- use 'steelsojka/pears.nvim' -- Neovim auto pair
  use 'kevinhwang91/nvim-bqf' -- Neovim Better Quickfix
  -- use 'rmagatti/auto-session' -- Neovim session management
  use 'numToStr/Comment.nvim' -- Neovim Commenting
  -- use 'folke/todo-comments.nvim' -- Neovim TODO Comment Highlighting
  -- use 'f-person/git-blame.nvim' -- Neovim Git Blame (shows via virtual text)
  -- use 'lewis6991/gitsigns.nvim' -- Neovim Git Stuffs (Depending on how much git we want to use, we might want to go this route)
  -- use {'ms-jpq/chadtree', branch = 'chad', run = 'python3 -m chadtree deps'} -- Neovim File Explorer with no external dependencies. Doesn't appear to have ssh support
  -- use {
  --   'kyazdani42/nvim-tree.lua', -- Neovim File Explorer with no external dependencies. Does appear to have _some_ form of ssh support 
  --   requires = {
  --     'kyazdani42/nvim-web-devicons', -- optional, for file icon
  --   },
  -- }
  use 'lukas-reineke/indent-blankline.nvim' -- Neovim indentation handling
  use 'tami5/sqlite.lua' -- Neovim SQlite database
  use {
    'nvim-treesitter/nvim-treesitter', -- Neovim Treesitter setup
    run = ':TSUpdate'
  }
  use 'nvim-telescope/telescope.nvim' -- Fuzzy Finder
  use 'sunjon/Shade.nvim' -- Neovim inactive window dimmer
  use 'norcalli/nvim-colorizer.lua' -- Neovim color highlighter
  -- use 'ahmedkhalf/project.nvim' -- Neovim project management
  -- use 'gbprod/substitute.nvim' -- Neovim better substitution
  -- use 'filipdutescu/renamer.nvim' -- Neovim vscode style variable renaming
  -- use 'ethanholz/nvim-lastplace' -- Neovim open file in the last place you were (if the file has been opened before?)
  -- use 'abecodes/tabout.nvim' -- Neovim tab escape parens?
  -- use 'rcarriga/nvim-notify' -- Neovim notifications?
  use 'romgrk/nvim-treesitter-context' -- Neovim code context
  -- use 'chipsenkbeil/distant.nvim' -- Neovim remote file editing (Note: Dependency https://github.com/chipsenkbeil/distant)
  -- use 'AckslD/nvim-neoclip.lua' -- Neovim Clipboard/register manager
    -- Also going to need to figure out how to get clipboard to play fair with tmux if we are running inside that. Or over ssh.
    -- Whatever it is, we need a better way of doing clipboard stuff. Maybe worth writing our own plugin for that????

  -- Utilies
  use 'nvim-lua/plenary.nvim' -- Neovim "Utility functions"
  -- use 'aserowy/tmux.nvim' -- Neovim Tmux integration
  -- use 'numToStr/Navigator.nvim' -- Neovim better pane handling

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
      require('packer').sync()
  end
end)

-- Plugin Configurations

local excluded_filetypes = {'lsp-installer', 'lspinfo', 'Outline', 'help', 'packer', 'netrw', 'qf', 'dbui', 'Trouble'}
vim.g['indent_blankline_filetype_exclude'] = excluded_filetypes
vim.g['db_ui_auto_execute_table_helpers'] = 1

require('indent_blankline').setup({
  show_current_context = true,
  show_current_context_start = true,
  use_treesitter = true
  -- space_char_blankline = ' ',
})


require('Comment').setup()
-- Probably should just have a theme.lua that we load?
require('onedarkpro').load()
require('lualine').setup{
  options = {
    theme = 'onedark',
    disabled_filetypes = excluded_filetypes,
  },
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
        }
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
      {
        'filetype',
        icon_only = true
      },
      'encoding', 'fileformat'
    },
    lualine_y = {
      'progress'
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
      'filename', 
    },
    lualine_x = {
    
    },
    lualine_y = {
      
    },
    lualine_z = {

    }
  }
}
require('cokeline').setup({
  components = {
    {
      text = function(buffer)
        return ' ' .. buffer.devicon.icon .. ' '
      end,
      hl = {
        fg = function(buffer)
          return buffer.devicon.color
        end
      }
    },
    {
      text = function(buffer)
        local status = ''
        if(buffer.is_readonly) then
          status = 'r'
        elseif(buffer.is_modified) then
          status = '🟡'
        end
        return status .. ' '
      end
    },
    {
      text = function(buffer)
        return buffer.unique_prefix .. buffer.filename
      end,
      hl = {
        fg = function(buffer)
          if(buffer.diagnostics.errors > 0) then
            return '#C95157'
          else
            return '#A4A8A5'
          end
        end,
        style = function(buffer)
          local text_style = 'NONE'
          if(buffer.is_focused) then
            text_style = 'bold'
          end
          if(buffer.diagnostics.errors > 0) then
            if(text_style ~= 'NONE') then
              text_style = text_style .. ',underline'
            else
              text_style = 'underline'
            end
          end
          return text_style
        end
      }
    },
    {
      text = ' ✖️ ',
      delete_buffer_on_left_click = true
    }

  },
  default_hl = {
    focused = {
      fg = '#A4A8A5',
      bg = '#3D3D3D',
    },
    unfocused = {
      fg = '#837F78',
      bg = '#1C1C1C',
    }
  },
  -- render = {
  --   right_separator = '╮',
  --   left_separator = '╭'
  -- }
})
require('specs').setup({
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
})

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

local luasnip = require('luasnip')
local lspkind = require('lspkind')
local cmp = require('cmp')

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
    ['<Tab>'] = cmp.mapping(cmp.mapping.confirm({select=true}), {'i', 'c'}),
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

local telescope = require('telescope')
local t_actions = require('telescope.actions')
telescope.setup({
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
    }
  }
})

require('trouble').setup({
  use_diagnostic_signs = true
})

-- Consider if we _actually_ need this... See if we can get the pieces of this we want into our own lua file instead of using a plugin
-- require('lspsaga').init_lsp_saga({

-- })
-- Maybe a better solution here?
require('treesitter-context').setup({

})

require('bqf').setup({
  
})
