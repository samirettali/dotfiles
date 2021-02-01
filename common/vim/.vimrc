syntax on

set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set backspace=indent,eol,start
set encoding=utf-8
set smarttab
set ttyfast
set hlsearch
set incsearch
set smartindent
set list
set listchars=tab:»·,trail:·,nbsp:~,eol:¬
set autoindent
set ignorecase
set smartcase
set undofile
set undodir=~/.vim/undo
set undolevels=1000
set undoreload=10000
set backupdir=~/.vim/backup
set directory=~/.vim/tmp
set number
set relativenumber
set splitbelow
set splitright
set incsearch
set cursorline
set hidden
set colorcolumn=81

nnoremap <silent> <C-n> :bnext<CR>
nnoremap <silent> <C-p> :bprev<CR>

nnoremap \ :vsplit<CR>
nnoremap - :split<CR>
nnoremap \| :vsplit 
nnoremap _ :split 

vmap < <gv
vmap > >gv

vmap <C-c> "+y
vmap <C-x> "+c
vmap <C-v> c<Esc>"+p
imap <C-v> <C-r><C-o>+"

colorscheme desert
hi ColorColumn ctermbg=red
