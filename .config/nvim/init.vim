" Automatically download vim-plug if not installed
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')
    " Writing
    Plug 'Raimondi/delimitMate'                 " Auto completion for quotes, brackets, etc.
    Plug 'norcalli/nvim-colorizer.lua'          " Show RGB colors
    Plug 'tpope/vim-commentary'                 " Add shortcuts to comment
    Plug 'tpope/vim-repeat'                     " Use . to repeat plugins motions
    Plug 'wincent/scalpel'                      " Replace words with shortcut

    " Formatting
    Plug 'godlygeek/tabular'                    " Align text automatically

    " Text objects
    Plug 'michaeljsmith/vim-indent-object'      " Add current indentation level object
    Plug 'machakann/vim-swap'                   " Swap delimited items
    Plug 'machakann/vim-textobj-delimited'      " Add delimiting object to strings
    Plug 'machakann/vim-sandwich'               " Add surround object for editing

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
    " Plug 'neomake/neomake'                    " Error checking
    Plug 'nvie/vim-flake8'                      " Python pep8 style
    Plug 'wellle/tmux-complete.vim'             " Autocomplete from tmux
    Plug 'tpope/vim-unimpaired'                 " Replace words with shortcut
    Plug 'fatih/vim-go'                         " Golang plugins
    Plug 'sheerun/vim-polyglot'                 " Better syntax highlighting

    " Auto completion
    Plug 'ncm2/ncm2'
    Plug 'roxma/nvim-yarp'
    Plug 'ncm2/ncm2-bufword'
    Plug 'ncm2/ncm2-path'
    Plug 'ncm2/ncm2-jedi'
    Plug 'ncm2/ncm2-go'

    " Development
    Plug 'AndrewRadev/splitjoin.vim'            " Split and join single and multiple lines
    Plug 'AndrewRadev/tagalong.vim'             " Automatically rename opening and closing tags
    Plug 'xuhdev/vim-latex-live-preview'        " Latex live preview
    Plug 'tpope/vim-markdown'                   " Markdown

    " Improving vim's functionalities
    Plug 'chrisbra/Recover.vim'                 " Show diff of a recovered or swap file
    Plug 'itchyny/lightline.vim'                " Status line
    Plug 'junegunn/vim-peekaboo'                " Show registers content before pasting
    Plug 'machakann/vim-highlightedyank'        " Hightlight yanked text
    Plug 'mbbill/undotree'                      " Creates an undo tree at forks
    Plug 'drzel/vim-split-line'                 " Split line at cursor
    Plug 'terryma/vim-expand-region'                 " Split line at cursor

    " Misc
    Plug 'justinmk/vim-syntax-extra'            " Add some syntax definitions
    Plug 'mileszs/ack.vim'                      " Ack plugin for vim
    Plug 'romainl/vim-cool'                     " Disable search highlighting automatically
    Plug 'tpope/vim-eunuch'                     " UNIX commands in vim
    Plug 'blueyed/vim-diminactive'            " Dim inactive splits
    " Plug 'camspiers/animate.vim'              " Animation for lens.vim
    Plug 'camspiers/lens.vim'                   " Auto resize small splits
    Plug 'vimwiki/vimwiki'                      " Personal wiki
    Plug 'AndrewRadev/switch.vim'               " Switch predefined values

    " Themes
    Plug 'ajh17/Spacegray.vim'
    Plug 'challenger-deep-theme/vim'
    Plug 'bluz71/vim-nightfly-guicolors'
    Plug 'dneto/spacegray-lightline'
    Plug 'lifepillar/vim-solarized8'
    Plug 'mhartington/oceanic-next'
    Plug 'dracula/vim', { 'as': 'dracula' }
call plug#end()

syntax on
filetype indent plugin on
set modelines=0
set synmaxcol=200                  " Don't highlight off screen lines

" Theme
if has('nvim') || has('termguicolors')
  set termguicolors
endif
colorscheme spacegray

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
set fillchars+=vert:\│              " Make vertical split separator full line
set encoding=utf-8
set foldmethod=indent
set foldclose=all
set foldlevelstart=20
set foldtext=MyFoldText()
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
set listchars=tab:»·,trail:·,nbsp:~,eol:¬ " Visualize tab, spaces and newlines
set backspace=indent,eol,start      " Make backspace behave properly "
set mouse=i                         " Allow mouse usage to copy over ssh
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

" Turn on wildmenu for file name tab completion
set wildmode=longest:full,full
set wildmenu

set cmdheight=1

" Color all columns from the 81st
let &colorcolumn=join(range(81,999),",")

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

" Mappings
imap <Up> <nop>
imap <Down> <nop>
imap <Left> <nop>
imap <Right> <nop>
nnoremap <Up>    <C-W>+
nnoremap <Down>  <C-W>-
nnoremap <Left>  3<C-W><
nnoremap <Right> 3<C-W>>

" Yank line without newline
nmap Y y$

" Do something smarter with enter and backspace (TODO)
nnoremap <BS> {
onoremap <BS> {
vnoremap <BS> {
nnoremap <expr> <CR> empty(&buftype) ? '}' : '<CR>'
onoremap <expr> <CR> empty(&buftype) ? '}' : '<CR>'
vnoremap <CR> }

" Compile using make file
" nnoremap <C-m> :make<CR>

" Better splits navigation
" nnoremap <C-j> <C-w><C-j>
" nnoremap <C-k> <C-w><C-k>
" nnoremap <C-l> <C-w><C-l>
" nnoremap <C-h> <C-w><C-h>

" Copy and paste using system clipboard
vmap <C-c> "+y
vmap <C-x> "+c
vmap <C-v> c<Esc>"+p
imap <C-v> <C-r><C-o>+"

" Select text inserted during last insert mode usage
nnoremap gV `[v`]

" Split faster 
nnoremap \ :vsplit<CR>
nnoremap - :split<CR>
nnoremap \| :vsplit 
nnoremap _ :split 

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
nnoremap <Leader>cc :let &cc = &cc == '' ? join(range(81, 999), ",") : ''<CR>

" Change vim directory into current buffer
nnoremap <Leader>cd :cd %:p:h<CR>

" Replace word with uppercase/lowercase/title case
nnoremap <Leader>u mzgUiw`za<Esc>
nnoremap <Leader>l mzguiw`za<Esc>
nnoremap <Leader>t :silent s/\<\(\w\)\(\S*\)/\u\1\L\2/g<CR>

" Keep text selected after indentation
vmap < <gv
vmap > >gv

" Open man page for word under cursor
map <Leader>m :call ReadMan()<CR>

" Format JSON
map <Leader>js :%!python -m json.tool<CR>

" Make word a link in markdown
map <Leader>lmd ysiw]wwa(<Esc>"+p)

" Quick commit and push
map <Leader>gw :!git add . && git commit -m 'WIP' && git push<CR>

" Debug print
let @d = "0"
map <Leader>pd oprint('debug ')<Esc>F "dp<C-a>"dyiw:w<CR>
map <Leader>cd oprintf("DEBUG \n");<Esc>5h"dp<C-a>"dyiw
" map <Leader>rd :g/^.*printf("DEBUG .*$/ d<CR>

" ROT 13
" nnoremap <Leader>13 ggVGg?<CR> 

" Plugins settings
" wimiki
autocmd FileType vimwiki set ft=markdown
let g:vimwiki_global_ext = 0
let g:vimwiki_list = [{'path': '~/Documents/wiki',
    \ 'syntax': 'markdown',
    \ 'ext': '.md',
    \ 'auto_export': 1}]

    " \ 'template_default': 'default',
    " \ 'template_ext': '.tpl',
    " \ 'template_path': '~/Documents/wiki/templates/',
    " \ 'html_filename_parametrization': 1,

" vim-polyglot
let g:python_highlight_all = 1

" vim-go
let g:go_highlight_array_whitespace_error = 1
let g:go_highlight_chan_whitespace_error = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_space_tab_error = 1
let g:go_highlight_trailing_whitespace_error = 1
let g:go_highlight_operators = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_string_spellcheck = 1
let g:go_highlight_format_strings = 1
let g:go_highlight_variable_declarations = 1
let g:go_highlight_variable_assignments = 1
let g:go_highlight_diagnostic_errors = 1
let g:go_highlight_diagnostic_warnings = 1
let g:go_auto_type_info = 1

" vim-sandwich
" runtime macros/sandwich/keymap/surround.vim

" Lens
let g:lens#disabled_filetypes = ['nerdtree', 'fzf', 'qf', 'vim-plug', 'tagbar']
let g:lens#height_resize_min = 5
let g:lens#width_resize_min = 20

" ncm2
" enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()
set completeopt=noinsert,menuone,noselect

" vim-markdown
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'js=javascript',
    \                              'c', 'asm', 'php']
let g:markdown_minlines = 100

" buftabline
let g:buftabline_numbers = 2

" highlightedyank
let g:highlightedyank_highlight_duration = 3000
let g:CoolTotalMatches = 1

" neomake
" call neomake#configure#automake('w')

" lightline
let g:lightline = {
\   'colorscheme': 'spacegray',
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
" Open NERDTree automatically when folder is opened
autocmd StdinReadPre * let s:std_in=1
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
let NERDTreeAutoDeleteBuffer = 1

" delimitMate
let delimitMate_matchpairs = "(:),[:],{:}"

" closetag
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.php'

" Plugins mappings

" ncm2
" inoremap <expr><Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" vim-expand-region
map K <Plug>(expand_region_expand)
map J <Plug>(expand_region_shrink)

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

" vim-split-line
nnoremap S :keeppatterns substitute/\s*\%#\s*/\r/e <bar> normal! ==<CR>

" nvim-colorizer
nnoremap <Leader>ct :ColorizerToggle<CR>

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

" Run flake8 on save
autocmd BufWritePost *.py call flake8#Flake8()

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

function! MyFoldText()
    let line = getline(v:foldstart)

    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let foldedlinecount = v:foldend - v:foldstart

    " expand tabs into spaces
    let onetab = strpart('          ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')
    let line = substitute(line, split(&foldmarker, ',')[0], '', '')

    let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount) - 9
    return line . ' ⤥ ' . repeat("…", fillcharcount) . ' (' . foldedlinecount .')'
endfunction

" Automatic Shebang
function! Hashbang(portable, permission, RemExt)
    let shells = { 
            \    'awk': "awk",
            \     'sh': "bash",
            \     'hs': "runhaskell",
            \     'jl': "julia",
            \    'lua': "lua",
            \    'mak': "make",
            \     'js': "node",
            \      'm': "octave",
            \     'pl': "perl", 
            \    'php': "php",
            \     'py': "python3",
            \      'r': "Rscript",
            \     'rb': "ruby",
            \  'scala': "scala",
            \    'tcl': "tclsh",
            \     'tk': "wish"
            \    }

    let extension = expand("%:e")

    if has_key(shells,extension)
        let fileshell = shells[extension]
        if a:portable
            let line =  "#!/usr/bin/env " . fileshell 
        else 
            let line = "#!" . system("which " . fileshell)
        endif
        0put = line
        exe 2
        if a:permission
            :autocmd BufWritePost * :autocmd VimLeave * :!chmod u+x %
        endif
        if a:RemExt
            :autocmd BufWritePost * :autocmd VimLeave * :!mv % "%:p:r"
        endif
    endif
endfunction

autocmd BufNewFile *.* :call Hashbang(1,1,0)

" Create non existent directories
augroup BWCCreateDir
  autocmd!
  autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END
fun! s:MkNonExDir(file, buf)
  if empty(getbufvar(a:buf, '&buftype')) && a:file !~# '\v^\w+\:\/'
    call mkdir(fnamemodify(a:file, ':h'), 'p')
  endif
endfun

" Exclude quickfix from bnext and bprev
augroup qf
    autocmd!
    autocmd FileType qf set nobuflisted
augroup END
