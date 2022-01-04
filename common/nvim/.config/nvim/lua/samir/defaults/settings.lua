local cmd = vim.cmd
local opt = vim.opt

local indentation = 4
local home = os.getenv("HOME")

opt.expandtab = true                -- Insert spaces instead of tabs
opt.tabstop = indentation           -- Tab size
opt.shiftwidth = indentation        -- Number of spaces to use for auto indenting
opt.smartindent = true
opt.ignorecase = true               -- Ignore case
opt.smartcase = true                -- Don't ignore case with capitals
opt.smarttab = true
opt.softtabstop = indentation
opt.autoindent = true               -- Automatically indent new lines

opt.synmaxcol = 200                 -- Highlight up to the 200th column

opt.undofile = true                 -- Use undo files
-- opt('b', 'spelllang', 'it,en_us')
-- opt.iskeyword = opt.iskeyword - { '_' }     -- Treat _ as a word separator


opt.number = true                   -- Show line numbers
opt.relativenumber = true           -- Show relative line numbers
opt.wrap = true                     -- Wrap visually long lines
opt.cursorline = true               -- Highlight current line
opt.colorcolumn = '81'              -- Highlight 81st column
opt.foldmethod = 'expr'             -- Set fold method
opt.signcolumn = 'yes'              -- Keep sign column always opened

opt.updatetime = 100
opt.hidden = true                   -- Enable modified buffers in background
opt.joinspaces = false              -- No double spaces with join after a dot
opt.scrolloff = 12                  -- Lines of context
opt.sidescrolloff = 8               -- Columns of context
opt.shiftround = true               -- Round indent
opt.splitbelow = true               -- Put new windows below current
opt.splitright = true               -- Put new windows right of current
opt.foldlevelstart = 20             -- Set initial fold level
opt.termguicolors = true            -- True color support
opt.wildmode = 'longest:full,full'  -- Command-line completion mode
opt.showmatch = true                -- Temporarily jump to matching parentheresis when inserting one
opt.confirm = true                  -- Ask for some operations like quitting an unsaved file instead of failing
opt.lazyredraw = true               -- Disable redrawing while running macros
opt.inccommand = 'nosplit'          -- Show result of substitution as you type
opt.mouse = 'nv'                    -- Enable mouse in normal and visual mode
opt.showbreak = '↳ '                -- Show character at visually wrapped lines
opt.listchars = 'tab:»·,trail:·,nbsp:~,eol:¬' -- Characters to visualize instead of whitespaces
opt.completeopt = 'menuone,noselect'
opt.undodir = home .. '/.local/share/nvim/undo'
opt.directory = home .. '/.local/share/nvim/swap'
opt.backupdir = home .. '/.local/share/nvim/tmp'
opt.shortmess = opt.shortmess + 'c'

cmd(':command! W w')
cmd(':command! Q q')
cmd(':command! WQ wq')
cmd(':command! Wq wq')

cmd('set foldexpr=nvim_treesitter#foldexpr()')

cmd('colorscheme moonfly')
