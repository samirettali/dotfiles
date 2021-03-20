local cmd = vim.cmd
local scopes = { o = vim.o, b = vim.bo, w = vim.wo}

local indentation = 2
local home = os.getenv("HOME")

local function opt(scope, key, value)
  scopes[scope][key] = value
  if scope ~= 'o' then
    scopes['o'][key] = value
  end
end

opt('b', 'expandtab', true)                -- Insert spaces instead of tabs
opt('b', 'tabstop', indentation)           -- Tab size
opt('b', 'shiftwidth', indentation)        -- Number of spaces to use for auto indenting
opt('b', 'smartindent', true)
opt('b', 'softtabstop', indentation)
opt('b', 'autoindent', true)
opt('b', 'synmaxcol', 200)                 -- Highlight up to the 200th column
opt('b', 'undofile', true)                 -- Use undo files
opt('b', 'spelllang', 'it,en_us')

opt('w', 'number', true)                   -- Show line numbers
opt('w', 'relativenumber', true)           -- Show relative line numbers
opt('w', 'wrap', true)                     -- Wrap visually long lines
opt('w', 'cursorline', true)               -- Highlight current line
opt('w', 'colorcolumn', '81')              -- Highlight 81st column

opt('o', 'hidden', true)                   -- Enable modified buffers in background
opt('o', 'ignorecase', true)               -- Ignore case
opt('o', 'smartcase', true)                -- Don't ignore case with capitals
opt('o', 'smarttab', true)
opt('o', 'joinspaces', false)              -- No double spaces with join after a dot
opt('o', 'scrolloff', 12)                  -- Lines of context
opt('o', 'sidescrolloff', 8)               -- Columns of context
opt('o', 'shiftround', true)               -- Round indent
opt('o', 'splitbelow', true)               -- Put new windows below current
opt('o', 'splitright', true)               -- Put new windows right of current
opt('o', 'termguicolors', true)            -- True color support
opt('o', 'wildmode', 'longest:full,full')  -- Command-line completion mode
opt('o', 'showmatch', true)                -- Temporarily jump to matching parentheresis when inserting one
opt('o', 'confirm', true)                  -- Ask for some operations like quitting an unsaved file instead of failing
opt('o', 'lazyredraw', true)               -- Disable redrawing while running macros
opt('o', 'inccommand', 'split')            -- Show result of substitution as you type
opt('o', 'mouse', 'nv')                    -- Enable mouse in normal and visual mode
opt('o', 'showbreak', '↳ ')                -- Show character at visually wrapped lines
opt('o', 'listchars', 'tab:»·,trail:·,nbsp:~,eol:¬') -- Characters to visualize instead of whitespaces
opt('o', 'completeopt', 'menuone,noselect')
opt('o', 'undodir', home .. '/.local/share/nvim/undo')
opt('o', 'directory', home .. '/.local/share/nvim/swap')
opt('o', 'backupdir', home .. '/.local/share/nvim/tmp')

vim.g.nvcode_termcolors=256

cmd('colorscheme nvcode')
cmd(':command! W w')
cmd(':command! Q q')
cmd(':command! WQ wq')
cmd(':command! Wq wq')
