#!/bin/sh

# Install NeoVim
brew install neovim

# Install vim-plug
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Configure NeoVim
mkdir -p ~/.config/nvim/
cat << EOF > ~/.config/nvim/init.vim
" Basic configurations
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set hlsearch
set autoindent
set incsearch
set colorcolumn=80

" Plugin configurations
call plug#begin()
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'preservim/nerdtree'
Plug 'tpope/vim-commentary'
call plug#end()

" Key mappings
let mapleader = ","
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>u :tabnew<CR>
nnoremap <leader>c gcc
nnoremap <leader>u gggT

nnoremap <leader>n :NERDTreeToggle<CR>

" Configure coc.nvim
let g:coc_global_extensions = [
    \ 'coc-tsserver',
    \ 'coc-json',
    \ 'coc-yaml',
    \ 'coc-html',
    \ 'coc-css',
    \ 'coc-python',
    \ 'coc-go',
    \ 'coc-jedi',
    \ ]
EOF

# Install plugins
nvim +PlugInstall +qall

