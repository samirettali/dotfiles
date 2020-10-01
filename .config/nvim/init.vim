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
    Plug 'mhinz/vim-signify'                    " Show git diff in the gutter
    Plug 'rhysd/committia.vim'                  " Better commit editing
    Plug 'tpope/vim-fugitive'                   " Git wrapper

    " Coding
    Plug 'jiangmiao/auto-pairs'                 " Auto completion for quotes, brackets, etc.
    Plug 'sheerun/vim-polyglot'                 " Better syntax highlighting
    Plug 'mattn/emmet-vim'                      " Emmet for vim
    Plug 'fatih/vim-go'                         " Golang plugins
    Plug 'tpope/vim-commentary'                 " Commenting plugin
    Plug 'majutsushi/tagbar'                    " Show a panel to browse tags
    Plug 'Valloric/MatchTagAlways'              " Highlight matching HTML tag
    Plug 'plasticboy/vim-markdown'              " Markdown improving
    Plug 'AndrewRadev/tagalong.vim'
    Plug 'Shougo/deoppet.nvim', { 'do': ':UpdateRemotePlugins' }
    Plug 'kana/vim-textobj-indent'
    Plug 'kana/vim-textobj-user'
    Plug 'prettier/vim-prettier', {
      \ 'do': 'yarn install',
      \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

    if has('nvim-0.5')
        Plug 'neovim/nvim-lspconfig'                " Language server protocol
        Plug 'nvim-lua/completion-nvim'             " Auto completion using LSP
        Plug 'nvim-lua/diagnostic-nvim'
    endif

    " Improving vim's functionalities
    Plug 'chrisbra/Recover.vim'                 " Show diff of a recovered or swap file
    Plug 'junegunn/vim-easy-align'              " Align stuff based on a symbol
    Plug 'christoomey/vim-tmux-navigator'       " Tmux splits integration
    Plug 'drzel/vim-split-line'                 " Split line at cursor
    Plug 'wincent/scalpel'                      " Replace word under cursor
    Plug 'tpope/vim-surround'                   " Add surround object for editing
    Plug 'machakann/vim-swap'                   " Swap delimited items
    Plug 'machakann/vim-textobj-delimited'      " More delimiting object
    Plug 'romainl/vim-cool'                     " Disable search highlighting on mode change
    Plug 'tpope/vim-repeat'                     " Repeat plugin mappings with .
    Plug 'norcalli/nvim-colorizer.lua'          " Show colors
    Plug 'justinmk/vim-sneak'                   " Adds a motion
    Plug 'tpope/vim-eunuch'                     " Adds UNIX commands
    Plug 'machakann/vim-highlightedundo'        " Highlights undo region
    Plug 'stefandtw/quickfix-reflector.vim'
    Plug 'wellle/targets.vim'                   " Add more targets for commands
    Plug 'vimwiki/vimwiki'
    Plug 'michal-h21/vimwiki-sync'

    " Lightline
    Plug 'itchyny/lightline.vim'                " Status line
    Plug 'mengelbrecht/lightline-bufferline'    " Show opened buffers in lightline

    " Colorscheme
    Plug 'bluz71/vim-moonfly-colors'
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
set tabstop=2                      " Number of spaces representing a TAB
set shiftwidth=2                   " Number of spaces for < and > command in vim
set softtabstop=2                  " Number of spaces corresponding to a TAB
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
set showmode
set formatoptions-=t
set history=1000                   " Increase history
set undofile                       " Create undo files
set undodir=~/.config/nvim/undo    " Undo files directory"
set undolevels=1000                " Number of undos allowed
set undoreload=10000
set backupdir=~/.config/nvim/tmp
set directory=~/.config/nvim/tmp
set autoread                       " Reload files if modified externally
set shell=zsh
set number                         " Show lines number
set relativenumber                 " Show relative line numbers
set fillchars+=vert:\│             " Make vertical split separator full line
set encoding=utf-8
set foldmethod=indent
set foldclose=all
set foldlevelstart=20
set splitbelow                     " More natural split
set splitright                     " More natural split
set complete=.,b,u,]
set cursorline                     " Highlight current line
set hidden                         " Allow buffer swap when modified
set path+=**
set nostartofline                  " Do not jump to first character with j/k
set showmatch                      " Show matching brackets
set confirm                        " Show confirmation instead of errors
set scrolloff=5                    " Keep 5 lines above and below the cursor
set sidescrolloff=5                " Keep 5 columns left and right of the cursor
set incsearch                      " Hightlight matches as you tipe
set inccommand=split               " Substitute words as you type
set wildignore=*.swp,*.bak,*.pyc,*.class
set listchars=tab:»·,trail:·,nbsp:~,eol:¬ " Visualize tab, spaces and newlines
set backspace=indent,eol,start     " Make backspace behave properly "
set mouse=i                        " Allow mouse usage to copy over ssh
set lazyredraw                     " Buffer screen updates
set timeout
set timeoutlen=500                 " Time to wait for key mapping
set ttimeoutlen=50                 " Time to wait for multikey mappings
set linebreak
set breakindent                    " Visually indent wrapped lines
set breakindentopt=shift:2         " Shift option for breakindent
set showbreak=↳
set spelllang=it,en_us
set updatetime=100
set colorcolumn=81 " Change background for columns > 80
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

" Delete trailing spaces
nmap <Leader>t :%s/\s\+$//e<CR>

" Go back to last selected file
nmap <Leader><Leader> <C-^>

" Reload vim configuration
nnoremap <silent> <Leader>rv :source $MYVIMRC<CR>
nnoremap <silent> <Leader>pi :source $MYVIMRC<CR> :PlugInstall<CR>

" Show invisible characters
nnoremap <silent> <Leader>i :set list!<CR>

" Toggle fold
nnoremap <Space> za

" Toggle colorcolumn
nnoremap <Leader>cc :let &cc = &cc == '' ? 81 : ''<CR>

" Keep text selected after indentation
vmap < <gv
vmap > >gv

map <silent> <Leader>o :only<CR>

" Plugins settings

" vimwiki
let g:vimwiki_global_ext = 0
let g:vimwiki_list = [{'path': '~/Documents/Notes', 'template_path': '~/Documents/Templates/',
    \ 'template_default': 'default', 'syntax': 'markdown', 'ext': '.md',
    \ 'path_html': '~/Documents/Wiki/', 'custom_wiki2html': 'vimwiki_markdown',
    \ 'html_filename_parameterization': 1,
    \ 'template_ext': '.tpl'}]

" nvim-colorizer.lua
lua require'colorizer'.setup()

" highlightedundo
nmap u     <Plug>(highlightedundo-undo)
nmap <C-r> <Plug>(highlightedundo-redo)
nmap U     <Plug>(highlightedundo-Undo)
nmap g-    <Plug>(highlightedundo-gminus)
nmap g+    <Plug>(highlightedundo-gplus)

" vim-sneak
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T

" Prettier
let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0
let g:prettier#quickfix_enabled = 0

" MatchTagAlways
let g:mta_use_matchparen_group = 1
let g:mta_filetypes = {
    \ 'html' : 1,
    \ 'xhtml' : 1,
    \ 'gohtmltmpl' : 1,
    \ 'xml' : 1,
    \ 'jinja' : 1,
    \}

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
let g:go_fmt_command = "goimports"
let g:go_addtags_transform = "snakecase"
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

" vim-cool
let g:CoolTotalMatches = 1

" lightline
let g:lightline = {
\   'colorscheme': 'moonfly',
\   'component_function': {
\       'gitbranch': 'fugitive#head'
\   },
\   'component_expand': {
\       'buffers': 'lightline#bufferline#buffers'
\   },
\   'component_type': {
\       'buffers': 'tabsel'
\   },
\   'active': {
\       'left': [ [ 'mode', 'paste', 'buffers' ],
\               [ 'readonly', 'modified' ] ],
\       'right': [ ['lineinfo', 'percent', 'gitbranch', 'filetype' ] ]
\   },
\ }

" Concealing
if has('conceal')
    set concealcursor=n
endif

function! ToggleConcealLevel()
    if &conceallevel == 0
        setlocal conceallevel=2
    else
        setlocal conceallevel=0
    endif
endfunction

nnoremap <silent> <C-c><C-y> :call ToggleConcealLevel()<CR>
au VimEnter * syntax keyword Statement lambda conceal cchar=λ
au VimEnter * hi! link Conceal Statement
au VimEnter * set conceallevel=2

" Fuzzy file finder
nnoremap <C-f> :Files<CR>
nnoremap <C-g> :GFiles<CR>
nnoremap <C-o> :Buffers<CR>
" nnoremap <C-l> :Lines<CR>

" ack
nnoremap <Leader>a :Ack!<Space>

" Tagbar
map <silent> <C-t> :TagbarToggle<CR>

" vim-split-line
" nnoremap S :SplitLine<CR>

" Scalpel
nmap <Leader>s <Plug>(Scalpel)

" vim-markdown
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0

" Various settings and autocommands
" LSP
if has('nvim-0.5')
  inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
  set completeopt=menuone,noinsert,noselect
  set shortmess+=c

  let g:diagnostic_enable_virtual_text = 1
  let g:diagnostic_virtual_text_prefix = ' '
  let g:diagnostic_enable_underline = 0
  let g:diagnostic_insert_delay = 1
  nmap dn :NextDiagnostic<CR>
  nmap dp :PrevDiagnostic<CR>

  " TODO change gi and C-k
  " vim.api.nvim_buf_set_keymap(bufnr, 'n', 'g0', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', opts)
  " vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gW', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opts)
  " pyls_ms
  " jsonls
  " htm
  " vuels
  " bashls
  " cssls
  " jedi_language_server

lua << EOF
  local nvim_lsp = require('nvim_lsp')

  local on_attach = function(_, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    require'diagnostic'.on_attach()
    require'completion'.on_attach()

    -- Mappings.
    local opts = { noremap=true, silent=true }
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e', '<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>', opts)
  end

  local servers = {'gopls', 'html', 'cssls', 'tsserver', 'jedi_language_server'}
  for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
      on_attach = on_attach,
    }
  end
EOF
endif

" Wrap text on markdown and latex files
autocmd BufRead,BufNewFile *.md,*.tex setlocal formatoptions+=t

" Remember cursor position
augroup vimrc-remember-cursor-position
    autocmd!
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | 
        \ exe "normal! g`\"" | endif
augroup END

" Disable continuation of comments
autocmd FileType * setlocal formatoptions-=cro

" Resize splits proportionally to window resize
autocmd VimResized * :wincmd =

" Exclude quickfix from bnext and bprev
augroup qf
    autocmd!
    autocmd FileType qf set nobuflisted
augroup END

" Highlight yanked text
if exists('##TextYankPost')
    augroup LuaHighlight
        autocmd!
        autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank()
    augroup END
endif

" Automatic shabang in new files
function! ShaBang(portable, permission, RemExt)
let shells = {
        \    'awk': "awk",
        \     'sh': "bash",
        \     'hs': "runhaskell",
        \     'jl': "julia",
        \    'lua': "lua",
        \    'mak': "make",
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
  if a:permission
    :autocmd BufWritePost * :autocmd VimLeave * :!chmod u+x %
  endif
  if a:RemExt
    :autocmd BufWritePost * :autocmd VimLeave * :!mv % "%:p:r"
  endif
  call cursor(2, 0)
endif

endfunction

autocmd BufNewFile *.* :call ShaBang(1,1,0)

" Abbreviations
autocmd FileType python iabbrev <buffer> im import
autocmd FileType python iabbrev <buffer> rt return
autocmd FileType python iabbrev <buffer> yl yield
autocmd FileType python iabbrev <buffer> fa false
autocmd FileType python iabbrev <buffer> tr true
autocmd FileType python iabbrev <buffer> br break
