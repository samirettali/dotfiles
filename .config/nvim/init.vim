" Automatically download vim-plug if not installed
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')

    " Moving
    " Plug 'matze/vim-move' " Move visually selected lines

    " Writing
    Plug 'godlygeek/tabular' " Align text automatically
    Plug 'chrisbra/Colorizer' " Show RGB colors
    Plug 'Raimondi/delimitMate' " Auto completion for quotes, brackets, etc.
    Plug 'wellle/tmux-complete.vim' " Autocomplete from tmux
    Plug 'scrooloose/nerdcommenter' " Add shortcuts to comment
    " Plug 'caigithub/a_pair' " Combine parenthesis in a vim object

    " Text objects
    " Plug 'machakann/vim-swap' " Swap delimited items
    Plug 'tpope/vim-surround' " Add surround object for editing
    Plug 'machakann/vim-textobj-delimited' " Add delimiting object to strings
    " Plug 'michaeljsmith/vim-indent-object' " Add current indentation level object

    " Deoplete
    " Plug 'roxma/nvim-yarp'
    " Plug 'Shougo/deoplete.nvim'
    " Plug 'roxma/vim-hug-neovim-rpc'

    " Coding
    " Plug 'szw/vim-tags'
    " Plug 'neomake/neomake'
    " Plug 'artur-shaik/vim-javacomplete2'

    " Python
    " Plug 'vim-scripts/indentpython.vim'

    " Latex
    Plug 'xuhdev/vim-latex-live-preview'

    " Markdown
    Plug 'plasticboy/vim-markdown'
    Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }

    " Linting and syntax
    Plug 'w0rp/ale'
    " Plug 'nvie/vim-flake8'
    " Plug 'PProvost/vim-ps1' " Powershell syntax
    " Plug 'vim-syntastic/syntastic'
    Plug 'Chiel92/vim-autoformat' " Code auto formatting

    " Auto completion
    " Plug 'Valloric/YouCompleteMe'

    " Git
    Plug 'rhysd/committia.vim' " Better commit editing
    Plug 'airblade/vim-gitgutter'
    Plug 'Xuyuanp/nerdtree-git-plugin'

    " Web development
    " Plug 'mattn/emmet-vim'
    " Plug 'alvan/vim-closetag'
    " Plug 'beanworks/vim-phpfmt'
    " Plug 'pangloss/vim-javascript'
    " Plug 'Valloric/MatchTagAlways'
    " Plug '2072/PHP-Indenting-for-VIm'
    " Plug 'othree/javascript-libraries-syntax.vim'
    " Plug 'captbaritone/better-indent-support-for-php-with-html'

    " Navigation
    Plug 'majutsushi/tagbar' " Show a panel to browse tags
    Plug 'ap/vim-buftabline' " Show a list of the current buffers
    Plug 'scrooloose/nerdtree' " Nerdtree file navigator
    Plug 'christoomey/vim-tmux-navigator' " Navigate between vim and tmux splits

    " Nerdtree
    Plug 'ryanoasis/vim-devicons'
    Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

    " Misc
    " Plug 'xolox/vim-misc'
    Plug 'mileszs/ack.vim'
    Plug 'romainl/vim-cool' " Disable search highlighting automatically
    Plug 'tpope/vim-eunuch' " UNIX commands in vim
    Plug 'mhinz/vim-startify' " Start screen for vim
    " Plug 'Yggdroot/indentLine' " Show lines for indentation level
    Plug 'itchyny/lightline.vim' " Status line
    " Plug 'junegunn/limelight.vim' " Show syntax only for current indentation level
    Plug 'justinmk/vim-syntax-extra' " Add some syntax definitions
    Plug 'machakann/vim-highlightedyank' " Hightlight yanked text

    " Themes
    " Plug 'sheerun/vim-polyglot'
    " Plug 'mhartington/oceanic-next'
    Plug 'ajh17/Spacegray.vim'
    Plug 'chriskempson/base16-vim'

    " To try
    " Plug 'terryma/vim-multiple-cursors'
    " Plug 'tmhedberg/SimpylFold'
call plug#end()

set nocompatible
syntax on
filetype indent plugin on
set modelines=0
set synmaxcol=200                  " Don't bother highlighting off screen lines

set termguicolors
set background=dark
" colorscheme base16-oceanicnext
" colorscheme spacegray
" colorscheme base16-tomorrow-night
" colorscheme base16-default-dark
colorscheme base16-bright

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
" set laststatus=0                 " Remove status bar
set textwidth=80
set colorcolumn=81
highlight ColorColumn guibg=#373b41
" match ErrorMsg '\%>80v.\+'
set wrap
set showmode
set formatoptions-=t
set history=1000
set undofile
set undodir=~/.config/nvim/undo
set undolevels=1000
set undoreload=10000
set backupdir=~/.config/nvim/tmp
set directory=~/.config/nvim/tmp
set autoread
set shell=zsh
set number                           " Show line number
set relativenumber                   " Show relative line numbers
set fillchars+=vert:\│               " Make vertical split separator full line"
set encoding=utf-8
set foldmethod=indent
set foldlevel=1
set foldclose=all
set splitbelow                       " More natural split
set splitright                       " More natural split
set complete=.,b,u,]
set cursorline
set hidden
set path+=**
set nostartofline                    " Do not jump to first character with j/k
set showmatch                        " Show matching brackets
" set ruler
set confirm
set wildmenu
set scrolloff=5
set incsearch
set wildignore=*.swp,*.bak,*.pyc,*.class
set listchars=tab:»·,trail:·,nbsp:~,eol:¶ " Visualize tab, spaces and newlines
set backspace=2
set mouse=n
set lazyredraw
set timeoutlen=1000 ttimeoutlen=0 " Wait 1 second for multikey mappings
set cpt-=t
set cpt-=i
set linebreak
set breakindent
set breakindentopt=shift:2
set showbreak=↳

set updatetime=100

" set clipboard^=unnamedplus " Use system clipboard

set completeopt=menuone,menu,longest
set wildmode=longest,list,full
set wildmenu
set completeopt+=longest

set cmdheight=1

:command! WQ wq
:command! Wq wq
:command! W w
:command! Q q

" MAPPINGS
" Auto indent pasted text
" nnoremap p p=`]<C-o>
" nnoremap P P=`]<C-o>""

noremap <up>    <C-W>+
noremap <down>  <C-W>-
noremap <left>  3<C-W><
noremap <right> 3<C-W>>

nnoremap j gj
nnoremap k gk

inoremap jj <Esc>

nnoremap <F1> <Esc>
inoremap <F1> <Esc>
vnoremap <F1> <Esc>

nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprev<CR>

nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-l> <C-w><C-l>
nnoremap <C-h> <C-w><C-h>

vmap <C-c> "+y
vmap <C-x> "+c
vmap <C-v> c<Esc>"+p
imap <C-v> <C-r><C-o>+"

" map ,c :-1read ~/.config/nvim/skeletons/c.sk<CR>5jA
map ,py :-1read ~/.config/nvim/skeletons/python.sk<CR>jA
map ,j o<Esc>:-1read ~/.config/nvim/skeletons/java.sk<CR>jA
imap ,j <Esc>:-1read ~/.config/nvim/skeletons/java.sk<CR>jA

nmap <F5> :set pastetoggle<CR>

" Move visually selected text block
" vnoremap J :m '>+1<CR>gv=gv
" vnoremap K :m '<-2<CR>gv=gv

" Select text inserted during last insert mode usage
nnoremap gV `[v`]

" Split faster 
nnoremap \ :vsplit 
nnoremap - :split 

" LEADER MAPPINGS
let mapleader = ","

nnoremap <Leader>o :only<CR>
" nnoremap <Leader>p :expand('%')<CR>
" nnoremap <Leader>pp :let @0=expand('%') <Bar> :Clip<CR> :echo expand('%')<CR>

nnoremap <Leader>q :bd<CR>
nnoremap <Leader>w :w<CR>
nnoremap <Leader>e :edit 

" map <Leader>h :set hlsearch!<Bar>set hlsearch?<CR>

" inoremap <Leader>s <Esc>:w<CR>
inoremap <Leader>q <Esc>:q<CR>
inoremap <Leader>w <Esc>:wq<CR>

" Open NERDTree on current file
nnoremap <silent> <Leader>v :NERDTreeFind<CR>

" Edit vimrc
" nnoremap <Leader>vv :edit $MYVIMRC<CR>

" Reload vim configuration
nnoremap <Leader>rv :source $MYVIMRC<CR>:PlugInstall<CR>

" Show invisible characters
nnoremap <silent> <Leader>l :set list!<CR>

" Copy paragraph
noremap <Leader>cp yap<S-}>p

" Align paragraph
" noremap <Leader>f =ip

" Add author java style
nnoremap <Leader>a o<CR>/**<CR>@author Samir Ettali<CR><BS>*/<CR><Esc>

" Comment block
map <Leader>b vaBgc<Esc>

" Remove empty lines

" Center line
" nnoremap <space> zz

" Toggle fold
nnoremap <space> za

nnoremap <Leader>1 yypVr=

nnoremap <Leader>n :call NumberToggle()<CR>
nnoremap <silent> <Leader>zs :call Zap()<CR>
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
nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>

" Compile using make file
nnoremap <Leader>m :make<CR>

" Java mappings
inoremap <Leader>pri <Esc>ISystem.out.println(<Esc>A);<Esc>
" inoremap <Leader>for <Esc>Ifor (int i = 0; i < <Esc>A; i++) {<enter>}<Esc>O
inoremap <Leader>if <Esc>Iif (<Esc>A) {<enter>}<Esc>O<Tab>

" C mappings
" map <Leader>df i#define 
" imap <Leader>df #define 
map <Leader>in i#include <.h><Esc>2hi
imap <Leader>in #include <.h><Esc>2hi
let @d = "0"
map <Leader>d oprintf("DEBUG \n");<Esc>5h"dp<C-a>"dyiw
map <Leader>rd :g/^.*printf("DEBUG .*$/ d<CR>
map <Leader>k o#include "/home/samir/code/c/library.c"<Esc>
inoremap <Leader>; <C-o>A;<Esc>
nnoremap <Leader>; A;<Esc>

" Termbin upload
" nmap <Leader>pb :!php ~/scripts/pastebin.php < %<CR>
" nmap <Leader>tb :!nc termbin.com 9999 < % \| xclip -sel clip<CR>

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

" PLUGIN SETTINGS
let g:lightline = { 'colorscheme' : 'Tomorrow_Night' }
let g:buftabline_numbers = 2
let g:deoplete#enable_at_startup = 1
" let g:neomake_open_list = 2
let g:NERDSpaceDelims = 1
let g:vimtex_view_method = 'zathura'
let g:livepreview_previewer = 'zathura'
let g:python3_host_prog = 'python3.7'
let g:highlightedyank_highlight_duration = 3000
let g:CoolTotalMatches = 1
autocmd FileType java setlocal omnifunc=javacomplete#Complete

" vim-latex-live-preview
let g:livepreview_previewer = 'okular'
let g:livepreview_cursorhold_recompile = 0

" markdown-preview
let g:mkdp_auto_start = 1

" ale
" let g:ale_set_loclist = 0
" let g:ale_set_quickfix = 1
" let g:ale_open_list = 1
" Enable completion where available.
let g:ale_completion_enabled = 1

" vim-nerdtree-syntax-highlight
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreePatternMatchHighlightFullName = 1
" Remove buffer when you delete a file from NERDTree
let NERDTreeAutoDeleteBuffer = 1
" Hide pyc files
let NERDTreeIgnore=['\.pyc$', '\~$']

" YouCompleteMe
let g:ycm_autoclose_preview_window_after_completion=1

" Javascript libraries syntax
let g:used_javascript_libs = 'angularjs,angularui,angularuirouter,jquery'

" Open NERDTree automatically when folder is opened
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
" Close vim when only window left open is NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" Clean NERDTree's UI
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

" Limelight
" Color name (:help cterm-colors) or ANSI code
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240

" Color name (:help gui-colors) or RGB color
let g:limelight_conceal_guifg = 'DarkGray'
let g:limelight_conceal_guifg = '#777777'

" Default: 0.5
let g:limelight_default_coefficient = 0.1

" Number of preceding/following paragraphs to include (default: 0)
let g:limelight_paragraph_span = 1

" Beginning/end of paragraph
"   When there's no empty line between the paragraphs
"   and each paragraph starts with indentation
let g:limelight_bop = '^\s'
let g:limelight_eop = '\ze\n^\s'

" Highlighting priority (default: 10)
"   Set it to -1 not to overrule hlsearch
let g:limelight_priority = -1

" Match tag always
let g:mta_filetypes = {
    \ 'html' : 1,
    \ 'xhtml' : 1,
    \ 'xml' : 1,
    \ 'jinja' : 1,
    \ 'php' : 1,
    \}

" DelimitMate
let delimitMate_matchpairs = "(:),[:],{:}"

" Closetag
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.php'

" PLUGIN MAPPINGS
map <silent> <F6> :ColorToggle<CR>
map <F7> :make<CR>
map <F8> :TagbarToggle<CR>
map <F9> :PrevColorScheme<CR>
map <F10> :NextColorScheme<CR>
map <F12> :lnext<CR>
map <C-n> :NERDTreeToggle<CR>

nnoremap <Leader>t :Tabularize /

" YouCompleteMe
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>


nmap <F3> <Plug>(JavaComplete-Imports-AddMissing)
imap <F3> <Plug>(JavaComplete-Imports-AddMissing)
nmap <F4> <Plug>(JavaComplete-Imports-AddSmart)
imap <F4> <Plug>(JavaComplete-Imports-AddSmart)

" noremap <F3> :Autoformat<CR>

let g:user_emmet_leader_key='<C-M>'

map f <Plug>Sneak_s
map F <Plug>Sneak_S

" TODO vim-multiple-cursors
let g:multi_cursor_use_default_mapping=0
" Default mapping
let g:multi_cursor_start_word_key      = '<Leader>m'
" let g:multi_cursor_select_all_word_key = '<A-n>'
" let g:multi_cursor_start_key           = 'g<C-n>'
" let g:multi_cursor_select_all_key      = 'g<A-n>'
" let g:multi_cursor_next_key            = '<C-n>'
" let g:multi_cursor_prev_key            = '<C-p>'
" let g:multi_cursor_skip_key            = '<C-x>'
" let g:multi_cursor_quit_key            = '<Esc>'

" FUNCTIONS
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

" Read pdf file
:command! -complete=file -nargs=1 Rpdf :r !pdftotext -nopgbrk <q-args> -

" Decompile java .class files
function! s:ReadClass(dir, classname)
    execute "cd " . a:dir
    execute "0read !javap -c " . a:classname
    1
    setlocal readonly
    setlocal nomodified
endfunction

" Set latest search register to empty string on insert event
autocmd InsertEnter * :let @/=""
autocmd InsertLeave * :let @/=""

" Resize splits proportionally to window resize
autocmd VimResized * :wincmd =

" PROGRAMMING SETTINGS
" Decompile class files
autocmd BufReadCmd *.class call <SID>ReadClass(expand("<afile>:p:h"), expand("<afile>:t:r"))

" Java class template
autocmd BufNewFile *.java exe "normal ipublic class " . expand('%:t:r') . " {\n}\<Esc>1G"

" Insert package name
" autocmd BufNewFile *.java call InsertJavaPackage()
function! InsertJavaPackage()
    let filename = expand("%")
    let filename = substitute(filename, "\.java$", "", "")
    let dir = getcwd() . "/" . filename
    let dir = substitute(dir, "^.*\/src\/", "", "")
    let dir = substitute(dir, "\/[^\/]*$", "", "")
    let dir = substitute(dir, "\/", ".", "g")
    let filename = substitute(filename, "^.*\/", "", "")
    let dir = "package " . dir . ";"
    let result = append(0, dir)
    let result = append(1, "")
    let result = append(2, "public class " . filename . " {")
    let result = append(3, "    ")
    let result = append(4, "}")
    exe 4
    :startinsert!
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

" Remember cursor position
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

" Disable continuation of comments
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Python PEP 8 style
" au BufNewFile,BufRead *.py
    " \ set tabstop=4
    " \ set softtabstop=4
    " \ set shiftwidth=4
    " \ set textwidth=79
    " \ set expandtab
    " \ set autoindent
    " \ set fileformat=unix

let g:clever_f_across_no_line = 1
let g:clever_f_fix_key_direction = 1
let g:clever_f_timeout_ms = 3000
