" show line numbers
set number

" 4 space tab
set tabstop=4
set softtabstop=0 noexpandtab
set shiftwidth=4

" disable arrowkeys
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

"não sei
set clipboard+=unnamedplus

set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc
