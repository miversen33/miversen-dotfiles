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

" function! HighlightWordUnderCursor()
"     let disabled_ft = ["qf", "fugitive", "nerdtree", "gundo", "diff", "fzf", "floaterm"]
"     if &diff || &buftype == "terminal" || index(disabled_ft, &filetype) >= 0
"         return
"     endif
"     if getline(".")[col(".")-1] !~# '[[:punct:][:blank:]]'
"         hi MatchWord cterm=undercurl gui=undercurl guibg=#3b404a
"         exec 'match' 'MatchWord' '/\V\<'.expand('<cword>').'\>/'
"     else
"         match none
"     endif
" endfunction
"
" augroup MatchWord
"   autocmd!
"   autocmd! CursorHold,CursorHoldI * call HighlightWordUnderCursor()
" augroup END

autocmd BufEnter * silent! lcd %:p:h
autocmd BufAdd netrw_* :let b:vim_current_word_disabled_in_this_buffer = 1

" == Remaps ==

noremap <silent> <C-j> :call WinMove('h')<CR>
noremap <silent> <C-k> :call WinMove('j')<CR>
noremap <silent> <C-i> :call WinMove('k')<CR>
noremap <silent> <C-l> :call WinMove('l')<CR>
nnoremap <silent> <C-f> :Autoformat<CR>
noremap <silent> <C-[> :Files<CR>
noremap <silent> <C-o> :split<CR>
noremap <silent> <C-p> :vsplit<CR>
nnoremap <silent> <C-e> :Lexplore<CR>
" nnoremap <silent> <C-D>h :call CocActionAsync('doHover')<cr>
if has("nvim")
  au TermOpen * tnoremap <buffer> <Esc> <c-\><c-n>
  au FileType fzf tunmap <buffer> <Esc>
endif
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"
imap <c-space> <Plug>(asyncomplete_force_refresh)
" tnoremap <Esc> <C-\><C-n>

" Highlight all instances of word under cursor, when idle.
" Useful when studying strange source code.
" Type z/ to toggle highlighting on/off.
" nnoremap z/ :if AutoHighlightToggle()<Bar>set hls<Bar>endif<CR>

" for normal mode - the word under the cursor
nmap <Leader>di <Plug>VimspectorBalloonEval
" for visual mode, the visually selected text
xmap <Leader>di <Plug>VimspectorBalloonEval


nmap <silent> <C-m> :TagbarToggle<CR>

" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" inoremap <silent><expr> <Tab>
"       \ pumvisible() ? "\<C-n>" :
"       \ <SID>check_back_space() ? "\<Tab>" :
"       \ coc#refresh()

" == Plugins ==
call plug#begin('~/.local/share/nvim/plugged')
Plug 'prabirshrestha/vim-lsp'
Plug 'honza/vim-snippets'
Plug 'sirver/ultisnips'
Plug 'thomasfaingnaert/vim-lsp-ultisnips'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'mattn/vim-lsp-settings'
Plug 'puremourning/vimspector'
Plug 'sheerun/vim-polyglot'
Plug 'ryanoasis/vim-devicons'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'kristijanhusak/vim-hybrid-material'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'jmcantrell/vim-virtualenv'
Plug 'majutsushi/tagbar'
Plug 'tomtom/tcomment_vim'
Plug 'vim-autoformat/vim-autoformat'
" Plug 'ervandew/supertab'
Plug 'dominikduda/vim_current_word'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-surround'
Plug 'vim-test/vim-test'
Plug 'tpope/vim-dispatch'
Plug 'alaviss/nim.nvim'
Plug 'mfussenegger/nvim-dap'

call plug#end()

" == Options ==
" Theme options
set background=dark

colorscheme hybrid_reverse
let g:airline_theme = 'deus'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_alt_sep = '>'
" let g:airline_statusline_ontop = 1
let g:CtrlSpaceDefaultMappingKey = "<C-space> "
let g:airline_powerline_fonts = 1

" autocmd VimEnter * :AirlineToggleWhitespace
" let g:airline#extensions#whitespace#enabled = 1

" Fzf Options
let g:fzf_layout = { 'window': { 'width': 0.95, 'height': 0.8 } }

let g:fzf_tags_command = 'ctags -R'
let g:fzf_commands_expect = 'alt-enter,ctrl-x'
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

let g:python3_host_prog="/usr/bin/python3"

let g:vim_current_word#highlight_delay = 500

" ===netrw settings
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 2
let g:netrw_altv = 1
let g:netrw_winsize = 25
let g:netrw_preview = 1
let b:netrw_alto=0
let g:netrw_silent=1
let g:netrw_keepdir=0

" Vimspector config
let g:vimspector_enable_mappings='VISUAL_STUDIO'
" mnemonic 'di' = 'debug inspect' (pick your own, if you prefer!)

" == General Options ==
syntax on

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
set cursorline
set nocp
set splitright
set splitbelow
set foldmethod=expr
  \ foldexpr=lsp#ui#vim#folding#foldexpr()
  \ foldtext=lsp#ui#vim#folding#foldtext()

if version >= 600
  filetype plugin indent on
endif

" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
" set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

