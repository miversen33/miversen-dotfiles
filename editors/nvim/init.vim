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
endfunction

" function! ToggleVExplore()

" endfunction

" function! AutoHighlightToggle()
"   let @/ = ''
"   if exists('#auto_highlight')
"     au! auto_highlight
"     augroup! auto_highlight
"     setl updatetime=4000
"     echo 'Highlight current word: off'
"     return 0
"   else
"     augroup auto_highlight
"       au!
"       au CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
"     augroup end
"     setl updatetime=500
"     echo 'Highlight current word: ON'
"     return 1
"   endif
" endfunction

" == Remaps ==

noremap <silent> <C-j> :call WinMove('h')<CR>
noremap <silent> <C-k> :call WinMove('j')<CR>
noremap <silent> <C-i> :call WinMove('k')<CR>
noremap <silent> <C-l> :call WinMove('l')<CR>
nnoremap <silent> <C-f> :Autoformat<CR>
noremap <silent> <C-[> :Files<CR>
noremap <silent> <C-o> :split<CR>
noremap <silent> <C-p> :vsplit<CR>
" noremap <silent> <C-\> :Vexplore<CR>
" Highlight all instances of word under cursor, when idle.
" Useful when studying strange source code.
" Type z/ to toggle highlighting on/off.
" nnoremap z/ :if AutoHighlightToggle()<Bar>set hls<Bar>endif<CR>

nmap <F8> :TagbarToggle<CR>

" Coc settings
" if has('nvim')
  " inoremap <silent><expr> <C-space> coc#refresh()
" else
  " inoremap <silent><expr> <c-@> coc#refresh()
" endif

" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
" inoremap <silent><expr> <TAB>
" \ pumvisible() ? "\<C-n>" :
" \ <SID>check_back_space() ? "\<TAB>" :
" \ coc#refresh()
" inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" ===netrw settings
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 2
let g:netrw_altv = 1
let g:netrw_winsize = 25
let g:netrw_preview = 1
let g:netrw_silent=1
" augroup ProjectDrawer
  " autocmd!
  " autocmd VimEnter * :Vexplore
" augroup END

" == Plugins ==
call plug#begin('~/.local/share/nvim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'puremourning/vimspector'
Plug 'sheerun/vim-polyglot'
Plug 'ryanoasis/vim-devicons'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" Plug 'jiangmiao/auto-pairs'
" Plug 'machakann/vim-sandwich'
" Plug 'tpope/vim-sleuth'
" Plug 'editorconfig/editorconfig-vim'
" Plug 'airblade/vim-gitgutter'
" Plug 'tpope/vim-fugitive'
" Plug 'tpope/vim-vinegar'
Plug 'kristijanhusak/vim-hybrid-material'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'jmcantrell/vim-virtualenv'
Plug 'majutsushi/tagbar'
Plug 'tomtom/tcomment_vim'
Plug 'vim-autoformat/vim-autoformat'
Plug 'ervandew/supertab'
" Plug 'neoclide/coc-snippets'
" Language Servers 
" Plug 'davidhalter/jedi-vim'
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
let g:airline_powerline_fonts = 1
" autocmd VimEnter * :AirlineToggleWhitespace
" let g:airline#extensions#whitespace#enabled = 1

" let g:jedi#completions_command = "<Tab>"
" let g:jedi#use_splits_not_buffers = "left"

" Fzf Options
let g:fzf_layout = { 'window': { 'width': 0.95, 'height': 0.8 } }
let g:fzf_tags_command = 'ctags -R'
let g:fzf_commands_expect = 'alt-enter,ctrl-x'

let g:python3_host_prog="/usr/bin/python3"

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
set hidden
set encoding=utf-8
set list
set listchars=tab:->,space:·
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
" set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
