let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged-new')

call plug#end()

noremap <silent> <A-k> :m .+1<CR>==
noremap <silent> <A-i> :m .-2<CR>==
noremap <silent> <A-a> :tabp<CR>
noremap <silent> <A-d> :tabn<CR>
noremap <silent> <A-j> :bprevious<CR>
noremap <silent> <A-l> :bnext<CR>
noremap <silent> <C-x> dd
noremap <silent> <C-X> ddO
noremap <silent> <C-j> <C-W><C-h>
noremap <silent> <C-l> <C-W><C-l>
noremap <silent> <C-i> <C-W><C-k>
noremap <silent> <C-k> <C-W><C-j>
noremap <C-s> :w<CR> :echo "Saved File"<CR>
inoremap <C-s> <esc>:w<CR> :echo "Saved File"<CR>
noremap <C-f> /
inoremap <C-f> <esc>/
