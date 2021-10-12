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

" == Remaps ==
nnoremap <silent> <C-h> :call WinMove('h')<CR>
nnoremap <silent> <C-j> :call WinMove('j')<CR>
nnoremap <silent> <C-k> :call WinMove('k')<CR>
nnoremap <silent> <C-l> :call WinMove('l')<CR>
nnoremap <silent> <C-p> :CtrlSpace O<CR>
nnoremap <silent> <C-[> :Files<CR>
nmap <F8> :TagbarToggle<CR>

" Coc settings
if has('nvim')
  inoremap <silent><expr> <Tab> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

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

" == Plugins ==
call plug#begin('~/.local/share/nvim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'puremourning/vimspector'
Plug 'sheerun/vim-polyglot'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" Plug 'jiangmiao/auto-pairs'
" Plug 'machakann/vim-sandwich'
" Plug 'tpope/vim-sleuth'
" Plug 'editorconfig/editorconfig-vim'
" Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
" Plug 'tpope/vim-vinegar'
Plug 'kristijanhusak/vim-hybrid-material'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'jmcantrell/vim-virtualenv'
Plug 'majutsushi/tagbar'
Plug 'tomtom/tcomment_vim'
Plug 'davidhalter/jedi-vim'
" Plug 'pappasam/coc-jedi', { 'do': 'yarn install --frozen-lockfile && yarn build', 'branch': 'main' }
" This appears fucky. For some reason the installation doesn't fail but
" doesn't work
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

let g:jedi#completions_command = "<Tab>"

" Fzf Options
let g:fzf_preview_window = ['right:50%', 'ctrl-/']

" == General Options ==
syntax on
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
set list listchars=space:·,tab:»\ ,extends:›,precedes:‹,nbsp:·,trail:·
filetype plugin on
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
