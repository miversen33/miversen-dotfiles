" Auto load plugin manager
" https://github.com/junegunn/vim-plug#on-demand-loading-of-plugins
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Key Mappings
noremap <silent> <SPACE> <Nop>
let mapleader = " "
let localleader = "'" "Im not sold on this yet
noremap <silent> <A-k> :m .+1<CR>==
noremap <silent> <A-i> :m .-2<CR>==
noremap <silent> <A-j> :tabp<CR>
noremap <silent> <A-l> :tabn<CR>
noremap <silent> <C-x> dd
noremap <silent> <C-X> ddO
noremap <leader>s :source $MYVIMRC<CR>
noremap <silent> <C-j> <C-W><C-h>
noremap <silent> <C-l> <C-W><C-l>
noremap <silent> <C-i> <C-W><C-k>
noremap <silent> <C-k> <C-W><C-j>
noremap <C-s> :w<CR> :echo "Saved File"<CR>
inoremap <C-s> <esc>:w<CR>i
inoremap <silent> <C-u> <esc>viwUi
noremap <silent> <C-u> viwU
inoremap <silent> <C-d> <esc>ddi
noremap <silent> <leader>' viw<esc>a"<esc>bi"<esc>lel
noremap <silent> <C-_> :Commentary<CR>
inoremap <silent> <C-_> <esc>:Commentary<CR>i
nmap <silent> <C-m> :TagbarToggle<CR>

" Plugins
call plug#begin("$HOME/.local/share/nvim/plugged")

Plug 'tpope/vim-commentary'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'mattn/vim-lsp-settings'
" Plug 'puremourning/vimspector'
Plug 'sheerun/vim-polyglot'
Plug 'kristijanhusak/vim-hybrid-material'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'jmcantrell/vim-virtualenv', { 'for': 'python' }
Plug 'majutsushi/tagbar'
Plug 'vim-autoformat/vim-autoformat'
Plug 'mfussenegger/nvim-dap'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

call plug#end()

" Settings
syntax on
set number
set numberwidth=2
set wrap
set background=dark

set number " show line numbers
set hlsearch " highlight all results
set ignorecase " ignore case in search
set incsearch " show search results as you type
set foldmethod=indent
set encoding=utf-8
set list
set listchars=tab:->,space:·
set cursorline
set nocp
set splitright
set splitbelow

colorscheme hybrid_reverse
let g:airline_theme = 'deus'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_alt_sep = '>'
" let g:airline_statusline_ontop = 1
let g:airline_powerline_fonts = 1

