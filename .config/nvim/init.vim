" Automatically download vim-plug if not installed
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')

    " Writing
    Plug 'Raimondi/delimitMate'                 " Auto completion for quotes, brackets, etc.
    Plug 'chrisbra/Colorizer'                   " Show RGB colors
    Plug 'tpope/vim-commentary'                 " Add shortcuts to comment
    Plug 'tpope/vim-repeat'                     " Use . to repeate plugins motions
    Plug 'wincent/scalpel'                      " Replace words with shortcut

    " Formatting
    Plug 'godlygeek/tabular'                    " Align text automatically
    Plug 'matze/vim-move'                       " Move visually selected lines

    " Text objects
    " Plug 'michaeljsmith/vim-indent-object'    " Add current indentation level object
    Plug 'machakann/vim-swap'                   " Swap delimited items
    Plug 'machakann/vim-textobj-delimited'      " Add delimiting object to strings
    Plug 'tpope/vim-surround'                   " Add surround object for editing

    " Navigation
    Plug 'ap/vim-buftabline'                    " Emulate tabs with buffers
    Plug 'christoomey/vim-tmux-navigator'       " Navigate between vim and tmux splits
    Plug 'majutsushi/tagbar'                    " Show a panel to browse tags

    " Fuzzy file finder
    Plug '/usr/local/opt/fzf'                   " Local fzf on Mac OS
    Plug 'junegunn/fzf.vim'                     " Fzf plugin

    " Snippets
    Plug 'SirVer/ultisnips'                     " Snippet completion
    Plug 'honza/vim-snippets'                   " Snippets collection

    " NERDTree
    Plug 'Xuyuanp/nerdtree-git-plugin'          " NERDTree git integration
    Plug 'ryanoasis/vim-devicons'               " NERDTree icons
    Plug 'scrooloose/nerdtree'                  " NERDTree file explorer
    Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

    " Git
    Plug 'airblade/vim-gitgutter'               " Show git diff in the gutter
    Plug 'rhysd/committia.vim'                  " Better commit editing
    Plug 'tpope/vim-fugitive'                   " Git wrapper

    " Linting and syntax
    Plug 'Chiel92/vim-autoformat'               " Code auto formatting
    " Plug 'neomake/neomake'                      " Error checking
    Plug 'nvie/vim-flake8'                      " Python pep8 style
    Plug 'wellle/tmux-complete.vim'             " Autocomplete from tmux

    " Auto completion
    Plug 'ncm2/ncm2'
    Plug 'roxma/nvim-yarp'
    Plug 'ncm2/ncm2-bufword'
    Plug 'ncm2/ncm2-path'
    Plug 'ncm2/ncm2-jedi'

    " General development
    Plug 'AndrewRadev/splitjoin.vim'            " Split and join single and multiple lines

    " Web development
    Plug 'AndrewRadev/tagalong.vim'             " Automatically rename opening and closing tags

    " Latex
    Plug 'xuhdev/vim-latex-live-preview'        " Latex live preview

    " Markdown
    Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }
    Plug 'plasticboy/vim-markdown'

    " Improving vim's functionalities
    Plug 'chrisbra/Recover.vim'                 " Show diff of a recovered or swap file
    Plug 'itchyny/lightline.vim'                " Status line
    Plug 'junegunn/vim-peekaboo'                " Show registers content before pasting
    Plug 'machakann/vim-highlightedyank'        " Hightlight yanked text

    " Misc
    Plug 'justinmk/vim-syntax-extra'            " Add some syntax definitions
    Plug 'mhinz/vim-startify'                   " Start screen for vim
    Plug 'mileszs/ack.vim'                      " Ack plugin for vim
    Plug 'romainl/vim-cool'                     " Disable search highlighting automatically
    Plug 'tpope/vim-eunuch'                     " UNIX commands in vim
    Plug 'xolox/vim-misc'                       " Required by colorscheme switcher

    " Themes
    Plug 'challenger-deep-theme/vim', { 'as': 'challenger-deep' }
    Plug 'chriskempson/base16-vim'
    Plug 'dracula/vim', { 'as': 'dracula' }
    Plug 'nanotech/jellybeans.vim'
    Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}

    " To try
    " Plug 'benmills/vimux'
    " Plug 'tpope/vim-obsession'
    " Plug 'janko/vim-test'


call plug#end()

syntax on
filetype indent plugin on
set modelines=0
set synmaxcol=200                  " Don't bother highlighting off screen lines

" Theme
if has('nvim') || has('termguicolors')
  set termguicolors
endif
set background=dark
colorscheme jellybeans

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
set fileformat=unix
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
set mouse=a
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

" set completeopt=menuone,menu,longest

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
imap <Up> <nop>
imap <Down> <nop>
imap <Left> <nop>
imap <Right> <nop>
nnoremap <Up>    <C-W>+
nnoremap <Down>  <C-W>-
nnoremap <Left>  3<C-W><
nnoremap <Right> 3<C-W>>

inoremap kk <Esc>
inoremap jj <Esc>

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

" Go back to last selected file
nmap <Leader><Leader> <C-^>

" Edit vim configuration
nnoremap <silent> <Leader>ev :edit $MYVIMRC<CR>
nnoremap <silent> <Leader>rv :source $MYVIMRC<CR>
nnoremap <silent> <Leader>pi :PlugInstall<CR>

" Show invisible characters
nnoremap <silent> <Leader>i :set list!<CR>

" Copy and paste paragraph
nnoremap <Leader>cp yap<S-}>p

" Toggle fold
nnoremap <Space> za

" Sort selected lines
vmap <Leader>o :!sort<CR>

" Draw underline with = symbol
nnoremap <Leader>1 yypVr=

" Remove empty lines
nnoremap <Leader>ze :g/^$/d<CR>

" Autoformat paragraph
nnoremap <Leader>af mavapgq'a

" Toggle colorcolumn
nnoremap <Leader>cc :let &cc = &cc == '' ? '81' : ''<CR>

" Change vim directory into current buffer
nnoremap <Leader>cd :cd %:p:h<CR>

" Replace word with uppercase/lowercase/title case
nnoremap <Leader>u mzgUiw`za<Esc>
nnoremap <Leader>l mzguiw`za<Esc>
nnoremap <Leader>t :silent s/\<\(\w\)\(\S*\)/\u\1\L\2/g<CR>

" Keep text selected after indentation
vmap < <gv
vmap > >gv

" Move between code blocks
nnoremap è [{
nnoremap + ]}
nnoremap à [(
nnoremap ù ])

" C coding mappings
let @d = "0"
map <Leader>d oprintf("DEBUG \n");<Esc>5h"dp<C-a>"dyiw
map <Leader>rd :g/^.*printf("DEBUG .*$/ d<CR>

" ROT 13
" nnoremap <Leader>13 ggVGg?<CR> 

" Plugins settings

" ncm2
" enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()
set completeopt=noinsert,menuone,noselect

" buftabline
let g:buftabline_numbers = 2

" highlightedyank
let g:highlightedyank_highlight_duration = 3000
let g:CoolTotalMatches = 1

" neomake
" call neomake#configure#automake('w')

" lightline
let g:lightline = {
\   'colorscheme': 'jellybeans',
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
autocmd Filetype tex setl updatetime=1

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

" ncm2
inoremap <expr><Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"


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
" autocmd BufWinEnter quickfix nnoremap <silent> <buffer>
"     \ q :cclose<cr>:lclose<cr>
" autocmd BufEnter * if (winnr('$') == 1 && &buftype ==# 'quickfix' ) |
"     \ bd|
"     \ q | endif

" Set latest search register to empty string on insert event
autocmd InsertEnter * :let @/=""
autocmd InsertLeave * :let @/=""

" Resize splits proportionally to window resize
autocmd VimResized * :wincmd =

" Run flake8 on save
autocmd BufWritePost *.py call flake8#Flake8()

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
