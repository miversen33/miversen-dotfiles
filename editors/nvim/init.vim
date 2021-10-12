" Auto loads vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" == Custom Functions ==

function! WinMove(key)
    let t:curwin = winnr()
    exec "wincmd ".a:key
"     if (t:curwin == winnr())
"         if (match(a:key,'[jk]'))
"             wincmd v
"         else
"             wincmd s
"         endif
"         exec "wincmd ".a:key
"     endif
endfunction

nnoremap <silent> <C-h> :call WinMove('h')<CR>
nnoremap <silent> <C-j> :call WinMove('j')<CR>
nnoremap <silent> <C-k> :call WinMove('k')<CR>
nnoremap <silent> <C-l> :call WinMove('l')<CR>
nnoremap <silent> <C-p> :CtrlSpace O<CR>

if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" ===netrw settings
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25
" augroup ProjectDrawer
"   autocmd!  
"   autocmd VimEnter * :Vexplore
"  augroup END

" == Options ==
syntax on " highlight syntax
filetype plugin on

set clipboard+=unnamedplus
set number " show line numbers
set hlsearch " highlight all results
set ignorecase " ignore case in search
set incsearch " show search results as you type
set nobackup
set nowritebackup
set foldmethod=indent
set foldlevel=99
set cmdheight=2
set hidden
set encoding=utf-8
set list
set listchars=space:·
" == Plugins ==
call plug#begin('~/.local/share/nvim/plugged')
" Plug 'tpope/vim-sensible'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'puremourning/vimspector'
" Plug 'sheerun/vim-polyglot'
" Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
" Plug 'junegunn/fzf.vim'
" Plug 'jiangmiao/auto-pairs'
" Plug 'machakann/vim-sandwich'
" Plug 'preservim/nerdcommenter'
" Plug 'tpope/vim-sleuth'
" Plug 'editorconfig/editorconfig-vim'
" Plug 'airblade/vim-gitgutter'
" Plug 'tpope/vim-fugitive'
" Plug 'tpope/vim-vinegar'
" Plug 'preservim/nerdtree'
Plug 'kristijanhusak/vim-hybrid-material'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'jmcantrell/vim-virtualenv'
call plug#end()

" == Options ==
" Theme options
set background=dark
colorscheme hybrid_reverse
let g:airline_theme = 'deus'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_alt_sep = '>'
let g:airline_statusline_ontop = 1
let g:CtrlSpaceDefaultMappingKey = "<C-space> "
