" Automatically download vim-plug if not installed
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')

    " Writing
    Plug 'tpope/vim-repeat'                     " Use . to repeate plugins motions
    Plug 'wincent/scalpel'                      " Replace words with shortcut
    Plug 'chrisbra/Colorizer'                   " Show RGB colors
    Plug 'Raimondi/delimitMate'                 " Auto completion for quotes, brackets, etc.
    Plug 'tpope/vim-commentary'                 " Add shortcuts to comment

    " Formatting
    Plug 'matze/vim-move'                       " Move visually selected lines
    Plug 'godlygeek/tabular'                    " Align text automatically

    " Text objects
    Plug 'machakann/vim-swap'                   " Swap delimited items
    Plug 'tpope/vim-surround'                   " Add surround object for editing
    Plug 'machakann/vim-textobj-delimited'      " Add delimiting object to strings
    " Plug 'michaeljsmith/vim-indent-object'    " Add current indentation level object

    " Navigation
    Plug 'majutsushi/tagbar'                    " Show a panel to browse tags
    Plug 'ap/vim-buftabline'                    " Emulate tabs with buffers
    Plug 'christoomey/vim-tmux-navigator'       " Navigate between vim and tmux splits

    " Fuzzy file finder
    Plug '/usr/local/opt/fzf'                   " Local fzf on Mac OS
    Plug 'junegunn/fzf.vim'                     " Fzf plugin

    " Snippets
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'

    " NERDTree
    Plug 'scrooloose/nerdtree'                  " Nerdtree file explorer
    Plug 'ryanoasis/vim-devicons'
    Plug 'Xuyuanp/nerdtree-git-plugin'
    Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

    " Git
    Plug 'tpope/vim-fugitive'
    Plug 'rhysd/committia.vim'                  " Better commit editing
    Plug 'airblade/vim-gitgutter'

    " Linting and syntax
    Plug 'neomake/neomake'                      " Error checking
    Plug 'Chiel92/vim-autoformat'               " Code auto formatting
    Plug 'Shougo/deoplete.nvim'
    Plug 'wellle/tmux-complete.vim'             " Autocomplete from tmux
    Plug 'nvie/vim-flake8'                      " Python pep8 style

    " Latex
    Plug 'xuhdev/vim-latex-live-preview'       " Latex live preview

    " Markdown
    Plug 'plasticboy/vim-markdown'
    Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }

    " Improving vim's functionalities
    Plug 'chrisbra/Recover.vim'                 " Show diff of a recovered or swap file
    Plug 'itchyny/lightline.vim'                " Status line
    Plug 'junegunn/vim-peekaboo'                " Show registers content before pasting
    Plug 'machakann/vim-highlightedyank'        " Hightlight yanked text

    " Misc
    Plug 'xolox/vim-misc'                       " Required by colorscheme switcher
    Plug 'mileszs/ack.vim'                      " Ack plugin for vim
    Plug 'romainl/vim-cool'                     " Disable search highlighting automatically
    Plug 'tpope/vim-eunuch'                     " UNIX commands in vim
    Plug 'mhinz/vim-startify'                   " Start screen for vim
    Plug 'justinmk/vim-syntax-extra'            " Add some syntax definitions

    " Themes
    Plug 'challenger-deep-theme/vim', { 'as': 'challenger-deep' }

    " To try
    Plug 'benmills/vimux'
    Plug 'tpope/vim-obsession'

    " Development
    " Plug 'janko/vim-test'


call plug#end()

set nocompatible
syntax on
filetype indent plugin on
set modelines=0
set synmaxcol=200                  " Don't bother highlighting off screen lines

" Theme
set termguicolors
set background=dark
colorscheme challenger_deep

set expandtab                      " Insert spaces instead of tabs
set tabstop=4                      " Number of spaces representing a tab
set shiftwidth=4                   " Number of spaces for < and > command in vim
set softtabstop=4
set shiftround
set smarttab
set smartindent
set autoindent
set ignorecase                     " Make searching case insensitive
set smartcase                      " Make search sensitive to capital letters
set noshowmode                     " Hide current vim mode because of lightline
set title
set textwidth=80
set colorcolumn=81                 " Color the 81st column
set wrap                           " Wrap lines longer than terminal width
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
set fillchars+=vert:\│              " Make vertical split separator full line"
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
set confirm
set scrolloff=5                     " Keep 5 lines above and below the cursor
set sidescrolloff=5                 " Keep 5 columns left and right of the cursor
set incsearch                       " Hightlight matches as you tipe
set wildignore=*.swp,*.bak,*.pyc,*.class
set listchars=tab:»·,trail:·,nbsp:~,eol:↲ " Visualize tab, spaces and newlines
set backspace=indent,eol,start      " Make backspace behave properly "
set mouse=n
set lazyredraw                      " Buffer screen updates
set timeout
set ttimeoutlen=50   " Time to wait for multikey mappings
set cpt-=t
set cpt-=i
set linebreak
set breakindent
set breakindentopt=shift:2
set showbreak=↳
set spelllang=it,en_us

set updatetime=100

set completeopt=menuone,menu,longest

" Turn on wildmenu for file name tab completion
set wildmode=longest:full,full
set wildmenu

set cmdheight=1

:command! WQ wq
:command! Wq wq
:command! W w
:command! Q q

" Functions
" Decompile java .class files
function! s:ReadClass(dir, classname)
    execute "cd " . a:dir
    execute "0read !javap -c " . a:classname
    1
    setlocal readonly
    setlocal nomodified
endfunction

" Display register, press a key and paste into the buffer
function! Reg()
    reg
    echo "Register: "
    let char = nr2char(getchar())
    if char != "\<Esc>"
        execute "normal! \"".char."p"
    endif
    redraw
endfunction
command! -nargs=0 Reg call Reg()

" Used for lightline
function! ObsessionStatus()
    return '%{ObsessionStatus()}'
endfunction

" Check battery status
" TODO check if file exists
" function! MyOnBattery()
"     return readfile('/sys/class/power_supply/AC/online') == ['0']
" endfunction

" Mappings
noremap <up>    <C-W>+
noremap <down>  <C-W>-
noremap <left>  3<C-W><
noremap <right> 3<C-W>>

" Compile using make file
nnoremap <C-m> :make<CR>

" Better splits navigation
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-l> <C-w><C-l>
nnoremap <C-h> <C-w><C-h>

" Copy and paste using system clipboard
vmap <C-c> "+y
vmap <C-x> "+c
vmap <C-v> c<Esc>"+p
imap <C-v> <C-r><C-o>+"

" Activate spelling
map <silent> <C-s> :setlocal spell!<CR>

" Open man page for word under cursor
map K :call ReadMan()<CR>

" Select text inserted during last insert mode usage
nnoremap gV `[v`]

" Split faster 
nnoremap \ :vsplit 
nnoremap - :split 

" Leader mappings
let mapleader = ","

" Edit vim configuration
nnoremap <silent> <Leader>ev :edit $MYVIMRC<CR>
nnoremap <silent> <Leader>rv :source $MYVIMRC<CR>
nnoremap <silent> <Leader>pi :PlugInstall<CR>

" Show invisible characters
nnoremap <silent> <Leader>i :set list!<CR>

" Copy paragraph
noremap <Leader>cp yap<S-}>p

" Toggle fold
nnoremap <space> za

" Draw underline with = symbol
nnoremap <Leader>1 yypVr=

" Remove empty lines
map <Leader>ze :g/^$/d<CR>

" Toggle colorcolumn
nnoremap <Leader>cc :let &cc = &cc == '' ? '81' : ''<CR>

" Change vim directory into current buffer
nnoremap <Leader>cd :cd %:p:h<CR>

" Replace word with uppercase/lowercase
nnoremap <Leader>u mzgUiw`za<Esc>
nnoremap <Leader>l mzguiw`za<Esc>

" Replace word with title case
" nnoremap <Leader>t :silent s/\<\(\w\)\(\S*\)/\u\1\L\2/g<CR>

" C mappings
let @d = "0"
map <Leader>d oprintf("DEBUG \n");<Esc>5h"dp<C-a>"dyiw
map <Leader>rd :g/^.*printf("DEBUG .*$/ d<CR>

" Keep text selected after indentation
vnoremap < <gv
vnoremap > >gv

" Move between code blocks
nnoremap è [{
nnoremap + ]}
nnoremap à [(
nnoremap ù ])

" ROT 13
" nnoremap <Leader>13 ggVGg?<CR> 

" Plugins settings

" buftabline
let g:buftabline_numbers = 2

" deoplete
let g:deoplete#enable_at_startup = 1
let g:python3_host_prog = 'python3.7'

" highlightedyank
let g:highlightedyank_highlight_duration = 3000
let g:CoolTotalMatches = 1

" neomake
call neomake#configure#automake('w')

" lightline
let g:lightline = {
\   'colorscheme': 'challenger_deep',
\   'active': {
\       'left': [ [ 'mode', 'paste' ],
\               [ 'readonly', 'modified' ] ],
\       'right': [ [ 'charhex', 'lineinfo', 'spell', 'gitbranch', 'filetype' ] ]
\   },
\   'component': {
\       'charhex': '0x%B'
\   },
\   'component_function': {
\       'gitbranch': 'fugitive#head'
\   },
\ }
" \       'obsession': 'ObsessionStatus'

" vim-latex-live-preview
let g:livepreview_previewer = 'open -a Preview'
let g:livepreview_cursorhold_recompile = 1

" ultiSnips
let g:UltiSnipsSnippetDirectories = [$HOME.'/.vim/UltiSnips']

" NERDTree
let g:NERDSpaceDelims = 1
autocmd StdinReadPre * let s:std_in=1                   " Open NERDTree automatically when folder is opened
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
" Close vim when only window left open is NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" Clean NERDTree's UI
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

" vim-nerdtree-syntax-highlight
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreePatternMatchHighlightFullName = 1
let NERDTreeAutoDeleteBuffer = 1                        " Remove buffer when you delete a file from NERDTree

" delimitMate
let delimitMate_matchpairs = "(:),[:],{:}"

" closetag
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.php'

" Plugins mappings

" Fuzzy file finder
nnoremap <C-f> :FZF<CR>

" NERDTree
nnoremap <silent> <Leader>v :NERDTreeFind<CR>
map <silent> <C-o> :NERDTreeToggle<CR>

" Tagbar
map <silent> <C-t> :TagbarToggle<CR>

" UltiSnips
let g:UltiSnipsExpandTrigger="<Leader>e"
let g:UltiSnipsJumpForwardTrigger="<C-b>"
let g:UltiSnipsJumpBackwardTrigger="<C-z>"

" buftabline
nnoremap <silent> <C-n> :bnext<CR>
nnoremap <silent> <C-p> :bprev<CR>

" deoplete
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" Scalpel
nmap <Leader>s <Plug>(Scalpel)

" Autocommands

" Wrap at column 80 on latex and markdown files
autocmd BufRead,BufNewFile *.md,*.tex setlocal formatoptions+=t

" Decompile class files
autocmd BufReadCmd *.class call <SID>ReadClass(expand("<afile>:p:h"), expand("<afile>:t:r"))

" Remember cursor position
augroup vimrc-remember-cursor-position
    autocmd!
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

" Disable continuation of comments
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Close vim when the only opened buffer is neomake error list
autocmd BufWinEnter quickfix nnoremap <silent> <buffer>
    \ q :cclose<cr>:lclose<cr>
autocmd BufEnter * if (winnr('$') == 1 && &buftype ==# 'quickfix' ) |
    \ bd|
    \ q | endif

" Set latest search register to empty string on insert event
autocmd InsertEnter * :let @/=""
autocmd InsertLeave * :let @/=""

" Resize splits proportionally to window resize
autocmd VimResized * :wincmd =

" Automatically insert java package and class name in new Java file
autocmd BufNewFile *.java call InsertJavaPackage()
function! InsertJavaPackage()
    let dir = getcwd()
    let dir = substitute(dir, "^.*\/src\/", "", "")
    let dir = substitute(dir, "\/", ".", "g")
    let dir = "package " . dir . ";"
    let result = append(0, dir)
    let filename = expand("%")
    let filename = substitute(filename, "\.java", "", "")
    let result = append(1, "")
    let result = append(2, "/**")
    let result = append(3, " * @author Samir Ettali")
    let result = append(4, " **/")
    let result = append(5, "")
    let result = append(6, "public class " . filename . " {")
    let result = append(7, "     ")
    let result = append(8, "}")
    call cursor(8, 5)
    startinsert
endfunction

fun! ReadMan()
    " Assign current word under cursor to a script variable:
    let s:man_word = expand('<cword>')
    " Open a new window:
    :exe ":wincmd n"
    " Read in the manpage for man_word (col -b is for formatting):
    :exe ":r!man " . s:man_word . " | col -b"
    " Goto first line...
    :exe ":goto"
    " and delete it:
    :exe ":delete"
    " finally set file type to 'man':
    :exe ":set filetype=man"
endfun
