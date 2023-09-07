#!/usr/bin/env lua
local cmd = vim.cmd
local opt = vim.opt
local g = vim.g

local indentation = 4
local home = os.getenv("HOME")

-- use filetype.lua instead of filetype.vim
-- g.did_load_filetypes = 0
-- g.do_filetype_lua = 1

opt.expandtab = true         -- Insert spaces instead of tabs
opt.tabstop = indentation    -- Tab size
opt.shiftwidth = indentation -- Number of spaces to use for auto indenting
opt.smartindent = true

-- Case insensitive search unless \C or capital in search
opt.ignorecase = true -- Ignore case
opt.smartcase = true  -- Don't ignore case with capitals

opt.smarttab = true
opt.softtabstop = indentation
opt.autoindent = true -- Automatically indent new lines

opt.synmaxcol = 200   -- Highlight up to the 200th column

opt.undofile = true   -- Use undo files
-- opt("b", "spelllang", "it,en_us")
-- opt.iskeyword = opt.iskeyword - { "_" }     -- Treat _ as a word separator

opt.number = true         -- Show line numbers
opt.relativenumber = true -- Show relative line numbers

opt.wrap = true           -- Wrap visually long lines
opt.foldmethod = "expr"   -- Set fold method
opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Keep sign column always opened
opt.signcolumn = "yes"

opt.background = "dark"

-- Decrease update time
opt.updatetime = 250
opt.timeoutlen = 400

opt.hidden = true       -- Enable having modified buffers in background
opt.joinspaces = false  -- No double spaces with join after a dot
opt.scrolloff = 12      -- Lines of context
opt.sidescrolloff = 8   -- Columns of context
opt.shiftround = true   -- Round indent
opt.splitbelow = true   -- Put new windows below current
opt.splitright = true   -- Put new windows right of current
opt.foldlevelstart = 20 -- Set initial fold level

-- True color support
opt.termguicolors = true

opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.showmatch = true -- Temporarily jump to matching parentheresis when inserting one
opt.lazyredraw = true -- Disable redrawing while running macros
opt.inccommand = "nosplit" -- Show result of substitution as you type
opt.mouse = "a" -- Enable mouse in all modes
opt.showbreak = "↳ " -- Show character at visually wrapped lines
opt.breakindent = true
opt.listchars = "tab:»·,trail:·,nbsp:~,eol:¬" -- Characters to visualize instead of whitespaces

opt.completeopt = "menuone,noselect"

opt.undodir = home .. "/.local/share/nvim/undo"
opt.directory = home .. "/.local/share/nvim/swap"
opt.backupdir = home .. "/.local/share/nvim/tmp"
opt.shortmess:append "c"
opt.shortmess:append "o" -- Don't print anything when writing a file

opt.clipboard = "unnamedplus"

opt.confirm = true    -- Ask for some operations like quitting an unsaved file instead of failing
opt.laststatus = 3    -- Global statusline
opt.title = true      -- Allow neovim to set the window title
opt.cmdheight = 1     -- Command line height
opt.cursorline = true -- Highlight current line
opt.showtabline = 0   -- Hide tabline

opt.showmode = false

opt.foldcolumn = "1"

opt.fillchars = {
    horiz = '━',
    horizup = '┻',
    horizdown = '┳',
    vert = '┃',
    vertleft = '┫',
    vertright = '┣',
    verthoriz = '╋',
    eob = " ",
    -- fold = "┈",
    -- diff = "┈",
    fold = " ",
    foldopen = "",
    foldsep = " ",
    foldclose = ""
}

g.gitblame_enabled = 0
g.editorconfig = true

-- vim.cmd [[highlight WinSeparator guibg=None guifg=#20272e]] -- Fix for the global statusline

cmd(":command! W w")
cmd(":command! Q q")
cmd(":command! WQ wq")
cmd(":command! Wq wq")


vim.schedule(function()
    vim.opt.shadafile = vim.fn.expand "$HOME" .. "/.local/share/nvim/shada/main.shada"
    vim.cmd [[ silent! rsh ]]
end)
