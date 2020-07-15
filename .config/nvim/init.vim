" Automatically download vim-plug if not installed
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')
    " External tools integrations
    Plug 'mileszs/ack.vim'                      " Ack integration
    Plug '/usr/local/opt/fzf'                   " Local fzf on Mac OS
    Plug 'junegunn/fzf.vim'                     " Fzf plugin

    " Git
    Plug 'airblade/vim-gitgutter'               " Show git diff in the gutter
    Plug 'rhysd/committia.vim'                  " Better commit editing
    Plug 'tpope/vim-fugitive'                   " Git wrapper

    " Coding
    Plug 'jiangmiao/auto-pairs'                 " Auto completion for quotes, brackets, etc.
    Plug 'fatih/vim-go'                         " Golang plugins
    Plug 'tpope/vim-commentary'                 " Commenting plugin
    Plug 'majutsushi/tagbar'                    " Show a panel to browse tags
    Plug 'neovim/nvim-lsp'                      " Language server protocol
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    Plug 'Shougo/deoplete-lsp'                  " Deoplete integration with LSP

    " Improving vim's functionalities
    Plug 'chrisbra/Recover.vim'                 " Show diff of a recovered or swap file
    Plug 'junegunn/vim-easy-align'              " Align stuff based on a symbol
    Plug 'christoomey/vim-tmux-navigator'       " Tmux splits integration
    Plug 'drzel/vim-split-line'                 " Split line at cursor
    Plug 'wincent/scalpel'                      " Replace word under cursor
    Plug 'machakann/vim-sandwich'               " Add surround object for editing
    Plug 'machakann/vim-swap'                   " Swap delimited items
    Plug 'machakann/vim-textobj-delimited'      " More delimiting object
    Plug 'romainl/vim-cool'                     " Disable search highlighting on mode change
    Plug 'tpope/vim-repeat'                     " Repeat plugin mappings with .
    " Plug 'plasticboy/vim-markdown'

    " Lightline
    Plug 'itchyny/lightline.vim'                " Status line
    Plug 'mengelbrecht/lightline-bufferline'    " Show opened buffers in lightline
    " Plug 'maximbaz/lightline-ale'               " Ale integration for lightline

    Plug 'bluz71/vim-moonfly-colors'

    " Remove?
    Plug 'sheerun/vim-polyglot'                 " Better syntax highlighting
    " Plug 'tpope/vim-unimpaired'                 " Replace words with shortcut
    " Plug 'deoplete-plugins/deoplete-jedi'       " Python autocompletion
    " Plug 'christoomey/vim-sort-motion'          " Sort motion
call plug#end()

syntax on
filetype indent plugin on
set modelines=0
set synmaxcol=200                  " Don't highlight off screen lines

" Theme
if has('nvim') || has('termguicolors')
  set termguicolors
endif
set background=dark
colorscheme moonfly

set expandtab                      " Use spaces for tabulation
set tabstop=4                      " Number of spaces representing a TAB
set shiftwidth=4                   " Number of spaces for < and > command in vim
set softtabstop=4                  " Number of spaces corresponding to a TAB
set shiftround                     " Round indentation to multiple of shiftwidth
set smarttab
set smartindent
set autoindent
set ignorecase                     " Make searching case insensitive
set smartcase                      " Make search sensitive to capital letters
set noshowmode                     " Hide current vim mode because of lightline
set title
set fileformat=unix
set textwidth=80
set wrap                           " Wrap lines longer than terminal width
set colorcolumn=81                " Highlight column
set showmode
set formatoptions-=t
set history=1000                   " Increase history
set undofile                       " Create undo files
set undodir=~/.config/nvim/undo    " Undo files directory"
set undolevels=1000                " Number of undos allowed
set undoreload=10000
set backupdir=~/.config/nvim/tmp
set directory=~/.config/nvim/tmp
set autoread                        " Reload files if modified externally
set shell=zsh
set number                          " Show lines number
set relativenumber                  " Show relative line numbers
set fillchars+=vert:\│              " Make vertical split separator full line
set encoding=utf-8
set foldmethod=indent
set foldclose=all
set foldlevelstart=20
set splitbelow                      " More natural split
set splitright                      " More natural split
set complete=.,b,u,]
set cursorline                      " Highlight current line
set hidden                          " Allow buffer swap when modified
set path+=**
set nostartofline                   " Do not jump to first character with j/k
set showmatch                       " Show matching brackets
set confirm                         " Show confirmation instead of errors
set scrolloff=5                     " Keep 5 lines above and below the cursor
set sidescrolloff=5                 " Keep 5 columns left and right of the cursor
set incsearch                       " Hightlight matches as you tipe
set inccommand=nosplit              " Substitute words as you type
set wildignore=*.swp,*.bak,*.pyc,*.class
set listchars=tab:»·,trail:·,nbsp:~,eol:¬ " Visualize tab, spaces and newlines
set backspace=indent,eol,start      " Make backspace behave properly "
set mouse=i                         " Allow mouse usage to copy over ssh
set lazyredraw                      " Buffer screen updates
set timeout
set timeoutlen=500                  " Time to wait for key mapping
set ttimeoutlen=50                  " Time to wait for multikey mappings
" set cpt-=t
" set cpt-=i
set linebreak
set breakindent                     " Visually indent wrapped lines
set breakindentopt=shift:2          " Shift option for breakindent
set showbreak=↳
set spelllang=it,en_us

set updatetime=100

" Turn on wildmenu for file name tab completion
" set wildmode=longest:full,full
" set wildmenu

set cmdheight=1

:command! WQ wq
:command! Wq wq
:command! W w
:command! Q q

" Yank line without newline
nmap Y y$

" Copy and paste using system clipboard
vmap <C-c> "+y
vmap <C-x> "+d

" Select text inserted during last insert mode usage
nnoremap gV `[v`]

" Split faster 
nnoremap \ :vsplit<CR>
nnoremap - :split<CR>
nnoremap \| :vsplit 
nnoremap _ :split 

" Buffer switching
nnoremap <silent> <C-n> :bnext<CR>
nnoremap <silent> <C-p> :bprev<CR>

" Leader mappings
let mapleader = ","

" Go back to last selected file
nmap <Leader><Leader> <C-^>

" Reload vim configuration
nnoremap <silent> <Leader>rv :source $MYVIMRC<CR>

" Show invisible characters
nnoremap <silent> <Leader>i :set list!<CR>

" Toggle fold
nnoremap <Space> za

" Toggle colorcolumn
nnoremap <Leader>cc :let &cc = &cc == '' ? 81 : ''<CR>

" Keep text selected after indentation
vmap < <gv
vmap > >gv

" Plugins settings

" deoplete
let g:deoplete#enable_at_startup = 1
call deoplete#custom#option('omni_patterns', { 'go': '[^. *\t]\.\w*' })

" vim-polyglot
let g:python_highlight_all = 1

" vim-go
let g:go_highlight_array_whitespace_error = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_chan_whitespace_error = 1
let g:go_highlight_diagnostic_errors = 1
let g:go_highlight_diagnostic_warnings = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_format_strings = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_functions = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_space_tab_error = 1
let g:go_highlight_string_spellcheck = 1
let g:go_highlight_structs = 1
let g:go_highlight_trailing_whitespace_error = 1
let g:go_highlight_types = 1
let g:go_highlight_variable_assignments = 1
let g:go_highlight_variable_declarations = 1
let g:go_auto_type_info = 1
" let g:go_auto_sameids = 1
let g:go_fmt_command = "goimports"
let g:go_addtags_transform = "snakecase"
au FileType go nmap <Leader>gt :GoDeclsDir<CR>
au FileType go nmap <Leader>gf <Plug>(go-def)

" vim-cool
let g:CoolTotalMatches = 1

" lightline
let g:lightline = {
\   'colorscheme': 'moonfly',
\   'component_function': {
\       'gitbranch': 'fugitive#head'
\   },
\   'active': {
\       'left': [ [ 'mode', 'paste', 'buffers' ],
\               [ 'readonly', 'modified' ] ],
\       'right': [ [ 'linter_checking', 'linter_errors', 'linter_warnings', 
\                    'linter_infos', 'linter_ok', 'lineinfo', 'spell', 
\                    'gitbranch', 'filetype' ] ]
\   },
\ }
let g:lightline.component_expand = {
      \ 'buffers': 'lightline#bufferline#buffers',
      \  'linter_checking': 'lightline#ale#checking',
      \  'linter_infos': 'lightline#ale#infos',
      \  'linter_warnings': 'lightline#ale#warnings',
      \  'linter_errors': 'lightline#ale#errors',
      \  'linter_ok': 'lightline#ale#ok',
      \ }
let g:lightline.component_type = {
      \     'buffers': 'tabsel',
      \     'linter_checking': 'right',
      \     'linter_infos': 'right',
      \     'linter_warnings': 'warning',
      \     'linter_errors': 'error',
      \     'linter_ok': 'right',
      \ }
let g:lightline#ale#indicator_checking = "\uf110"
let g:lightline#ale#indicator_infos = "\uf129"
let g:lightline#ale#indicator_warnings = "\uf071"
let g:lightline#ale#indicator_errors = "\uf05e"
let g:lightline#ale#indicator_ok = "\uf00c"

" For conceal markers.
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif

" Fuzzy file finder
nnoremap <C-f> :FZF<CR>

" ack
nnoremap <Leader>a :Ack!<Space>

" Tagbar
map <silent> <C-t> :TagbarToggle<CR>

" vim-split-line
nnoremap S :SplitLine<CR>

" Scalpel
nmap <Leader>s <Plug>(Scalpel)

" vim-markdown
let g:vim_markdown_conceal_code_blocks = 0

" Wrap text on markdown and latex files
autocmd BufRead,BufNewFile *.md,*.tex setlocal formatoptions+=t

" Remember cursor position
augroup vimrc-remember-cursor-position
    autocmd!
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

" Disable continuation of comments
autocmd FileType * setlocal formatoptions-=cro

" Close vim when the only opened buffer is quickfix
autocmd BufWinEnter quickfix nnoremap <silent> <buffer>
    \ q :cclose<cr>:lclose<cr>
autocmd BufEnter * if (winnr('$') == 1 && &buftype ==# 'quickfix' ) |
    \ bd|
    \ q | endif

" Resize splits proportionally to window resize
autocmd VimResized * :wincmd =

" Exclude quickfix from bnext and bprev
augroup qf
    autocmd!
    autocmd FileType qf set nobuflisted
augroup END

" Highlight yanked text
augroup LuaHighlight
  autocmd!
  autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank()
augroup END

" Do not show colorcolumn for certain file types
autocmd FileType html setlocal colorcolumn=
autocmd FileType template setlocal colorcolumn=

lua << EOF
    require'nvim_lsp'.gopls.setup{}
EOF
