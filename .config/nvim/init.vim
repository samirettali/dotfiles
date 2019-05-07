" Automatically download vim-plug if not installed
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')

    " Writing
    " Plug 'caigithub/a_pair'                   " Combine parenthesis in a vim object
    Plug 'tpope/vim-repeat'                     " Use . to repeate plugins motions
    Plug 'junegunn/goyo.vim'                    " Minimal UI
    Plug 'chrisbra/Colorizer'                   " Show RGB colors
    Plug 'Raimondi/delimitMate'                 " Auto completion for quotes, brackets, etc.
    Plug 'tpope/vim-commentary'                 " Add shortcuts to comment
    Plug 'wincent/scalpel'                      " Replace words with shortcut
    Plug 'wellle/tmux-complete.vim'             " Autocomplete from tmux

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

    " NERDTree
    Plug 'scrooloose/nerdtree'                  " Nerdtree file navigator
    Plug 'ryanoasis/vim-devicons'
    Plug 'Xuyuanp/nerdtree-git-plugin'
    Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

    " Git
    Plug 'tpope/vim-fugitive'
    Plug 'rhysd/committia.vim'                  " Better commit editing
    Plug 'airblade/vim-gitgutter'

    " Linting and syntax
    Plug 'neomake/neomake'                      " Error checking
    Plug 'sheerun/vim-polyglot'                 " Better syntax highlighting for languages
    Plug 'Chiel92/vim-autoformat'               " Code auto formatting
    Plug 'Shougo/deoplete.nvim'
    " Plug 'artur-shaik/vim-javacomplete2'

    " Latex
    Plug 'xuhdev/vim-latex-live-preview'       " Latex live preview

    " Markdown
    Plug 'plasticboy/vim-markdown'
    Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }

    " Misc
    Plug 'xolox/vim-misc'                       " Required by colorscheme switcher
    Plug 'mileszs/ack.vim'                      " Ack plugin for vim
    Plug 'romainl/vim-cool'                     " Disable search highlighting automatically
    Plug 'tpope/vim-eunuch'                     " UNIX commands in vim
    Plug 'mhinz/vim-startify'                   " Start screen for vim
    Plug 'Yggdroot/indentLine'                  " Show lines for indentation level
    Plug 'itchyny/lightline.vim'                " Status line
    Plug 'justinmk/vim-syntax-extra'            " Add some syntax definitions
    Plug 'machakann/vim-highlightedyank'        " Hightlight yanked text

    " Snippets
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'

    " To try
    " Plug 'tmhedberg/SimpylFold'
    Plug 'benmills/vimux'
    Plug 'tpope/vim-obsession'

    " Themes
    Plug 'dracula/vim'
    Plug 'ayu-theme/ayu-vim'
    Plug 'ajh17/Spacegray.vim'
    Plug 'chriskempson/base16-vim'
    Plug 'mhartington/oceanic-next'
    Plug 'rafi/awesome-vim-colorschemes'
    Plug 'xolox/vim-colorscheme-switcher'
call plug#end()

set nocompatible
syntax on
filetype indent plugin on
set modelines=0
set synmaxcol=200                  " Don't bother highlighting off screen lines

set termguicolors
set background=dark
let themes = ['deep-space', 'dracula', 'base16-tomorrow-night', 'hybrid', 'hybrid_material', 'hybrid_reverse', 'OceanicNext', 'onedark', 'spacegray']
execute 'colorscheme '.themes[localtime() % len(themes)]
unlet themes

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
set colorcolumn=81
highlight ColorColumn ctermbg=Red
set wrap
set showmode
set formatoptions-=t
set history=1000                   " Increase history
set undofile
set undodir=~/.config/nvim/undo
set undolevels=1000
set undoreload=10000
set backupdir=~/.config/nvim/tmp
set directory=~/.config/nvim/tmp
set autoread                        " Reload files if modified externally
set shell=zsh
set number                          " Show line number
set relativenumber                  " Show relative line numbers
set fillchars+=vert:\│              " Make vertical split separator full line"
set encoding=utf-8
set foldmethod=indent
set foldlevel=1
set foldclose=all
set splitbelow                      " More natural split
set splitright                      " More natural split
set complete=.,b,u,]
set cursorline
set hidden
set path+=**
set nostartofline                   " Do not jump to first character with j/k
set showmatch                       " Show matching brackets
set confirm
set wildmenu
set scrolloff=5                     " Keep 5 lines above and below the cursor
set sidescrolloff=5                 " Keep 5 columns left and right of the cursor
set incsearch                       " Hightlight matches as you tipe
set wildignore=*.swp,*.bak,*.pyc,*.class
set listchars=tab:»·,trail:·,nbsp:~,eol:¶ " Visualize tab, spaces and newlines
set backspace=2
set mouse=n
set lazyredraw                      " Buffer screen updates
set timeoutlen=1000 ttimeoutlen=0   " Wait 1 second for multikey mappings
set cpt-=t
set cpt-=i
set linebreak
set breakindent
set breakindentopt=shift:2
set showbreak=↳

set updatetime=100

" set clipboard^=unnamedplus " Use system clipboard

set completeopt=menuone,menu,longest

" Turno on wildmenu for file name tab completion
set wildmode=longest,list,full
set wildmenu

set cmdheight=1

:command! WQ wq
:command! Wq wq
:command! W w
:command! Q q

" Functions
function! Zap()
    let l:pos=getcurpos()
    let l:search=@/
    keepjumps %/\s\+$//e
    let @/=l:search
    nohlsearch
    call setpos('.', l:pos)
endfunction

function! NumberToggle()
    if(&relativenumber == 1)
        set nornu
        set number
    else
        set rnu
    endif
endfunc

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
function! MyOnBattery()
    return readfile('/sys/class/power_supply/AC/online') == ['0']
endfunction


" Mappings
noremap <up>    <C-W>+
noremap <down>  <C-W>-
noremap <left>  3<C-W><
noremap <right> 3<C-W>>

nnoremap j gj
nnoremap k gk

" Compile using make file
nnoremap <C-m> :make<CR>

nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprev<CR>

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

" Select text inserted during last insert mode usage
nnoremap gV `[v`]

" Split faster 
nnoremap \ :vsplit 
nnoremap - :split 

" Leader mappings
let mapleader = ","

" nnoremap <Leader>p :expand('%')<CR>
" nnoremap <Leader>pp :let @0=expand('%') <Bar> :Clip<CR> :echo expand('%')<CR>

" Reload vim configuration
nnoremap <Leader>rv :source $MYVIMRC<CR>:PlugInstall<CR>

" Show invisible characters
nnoremap <silent> <Leader>l :set list!<CR>

" Copy paragraph
noremap <Leader>cp yap<S-}>p

" Toggle fold
nnoremap <space> za

" Draw underline with = symbol
nnoremap <Leader>1 yypVr=

" Toggle numeration mode
nnoremap <Leader>n :call NumberToggle()<CR>

" Trim whitespaces
nnoremap <silent> <Leader>zs :call Zap()<CR>

" Remove empty lines
map <Leader>ze :g/^$/d<CR>

" Toggle colorcolumn
nnoremap <Leader>co :let &cc = &cc == '' ? '81' : ''<CR>

" Replace under cursor and continue replacing with .
nnoremap <Leader>x *``xgn
nnoremap <Leader>X #``cgN

" Same thing as above but case sensitive
" nnoremap <Leader>x /\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgn
" nnoremap <Leader>X ?\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgN

" Change vim directory into current buffer
nnoremap <Leader>cd :cd %:p:h<CR>

" Replace word with uppercase/lowercase
nnoremap <Leader>uc mzgUiw`za<Esc>
nnoremap <Leader>lc mzguiw`za<Esc>

" Replace word with title case
" nnoremap <Leader>t :silent s/\<\(\w\)\(\S*\)/\u\1\L\2/g<CR>

" Replace word globally
 nmap <Leader>s <Plug>(Scalpel)

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
nnoremap <Leader>13 ggVGg?<CR> 

" Plugins settings
" buftabline
let g:buftabline_numbers = 2

" deoplete
let g:deoplete#enable_at_startup = 1
let g:python3_host_prog = 'python3.7'

" highlightedyank
let g:highlightedyank_highlight_duration = 3000
let g:CoolTotalMatches = 1

" java-omnicomplete
autocmd FileType java setlocal omnifunc=javacomplete#Complete

" neomake
let g:neomake_open_list = 2
if MyOnBattery()
    call neomake#configure#automake('w')
else
    call neomake#configure#automake('nrwi', 500)
endif

" lightline
let g:lightline = {
\   'colorscheme': 'wombat',
\   'active': {
\       'left': [ [ 'mode', 'paste' ],
\               [ 'readonly', 'filename', 'modified' ] ],
\       'right': [ [ 'lineinfo' ],
\                [ 'percent' ],
\                [ 'obsession', 'fileformat', 'fileencoding', 'filetype', 'charvaluehex' ] ]
\   },
\   'component_function': {
\       'obsession': 'ObsessionStatus'
\   },
\ }

" vim-latex-live-preview
let g:livepreview_previewer = 'okular'
let g:livepreview_cursorhold_recompile = 0

" markdown-preview
let g:mkdp_auto_start = 1

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

" Plugin mappings
" Open NERDTree on current file
nnoremap <silent> <Leader>v :NERDTreeFind<CR>

map <silent> <F6> :ColorToggle<CR>
map <F8> :TagbarToggle<CR>
map <F9> :PrevColorScheme<CR>
map <F10> :NextColorScheme<CR>
map <F12> :lnext<CR>
map <C-n> :NERDTreeToggle<CR>
map <C-f> :FZF<CR>

nmap <F3> <Plug>(JavaComplete-Imports-AddMissing)
imap <F3> <Plug>(JavaComplete-Imports-AddMissing)
nmap <F4> <Plug>(JavaComplete-Imports-AddSmart)
imap <F4> <Plug>(JavaComplete-Imports-AddSmart)

map f <Plug>Sneak_s
map F <Plug>Sneak_S

" UltiSnips
let g:UltiSnipsExpandTrigger="<C-s>"
let g:UltiSnipsJumpForwardTrigger="<C-b>"
let g:UltiSnipsJumpBackwardTrigger="<C-z>"


" Autocommands
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
\   q :cclose<cr>:lclose<cr>
autocmd BufEnter * if (winnr('$') == 1 && &buftype ==# 'quickfix' ) |
\   bd|
\   q | endif

" Set latest search register to empty string on insert event
autocmd InsertEnter * :let @/=""
autocmd InsertLeave * :let @/=""

" Resize splits proportionally to window resize
autocmd VimResized * :wincmd =
