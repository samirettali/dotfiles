local home = os.getenv("HOME")

-- Tabs
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.smarttab = true

vim.opt.autoindent = true
vim.opt.cindent = true
vim.opt.wrap = true

vim.opt.breakindent = true
vim.opt.showbreak = "↳ "
vim.opt.linebreak = true

-- Case insensitive search unless \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.synmaxcol = 200 -- Highlight up to the 200th column

-- Use undo files
vim.opt.undofile = true
vim.opt.iskeyword = vim.opt.iskeyword - { "_" } -- Treat _ as a word separator

-- Show relative line numbers
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.foldmethod = "expr" -- Set fold method
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevelstart = 20 -- Set initial fold level

-- Keep sign column always opened
vim.opt.signcolumn = "yes"

vim.opt.background = "dark"

-- Fast!
vim.opt.timeoutlen = 400

vim.opt.hidden = true      -- Enable having modified buffers in background
vim.opt.joinspaces = false -- No double spaces with join after a dot
vim.opt.scrolloff = 10     -- Lines of context
vim.opt.sidescrolloff = 8  -- Columns of context
vim.opt.shiftround = true  -- Round indent
vim.opt.splitbelow = true  -- Put new windows below current
vim.opt.splitright = true  -- Put new windows right of current

-- True color support
vim.opt.termguicolors = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.pumheight = 15            -- Maximum of 15 elements shown in command auto completion
vim.opt.wildmode = "longest:full" -- Command-line completion mode
vim.opt.wildoptions = "pum"

vim.opt.showmatch = true       -- Temporarily jump to matching parentheresis when inserting one
vim.opt.lazyredraw = true      -- Disable redrawing while running macros
vim.opt.inccommand = "nosplit" -- Show result of substitution as you type

vim.opt.mouse = "a"

vim.opt.listchars = "tab:»·,trail:·,nbsp:~,eol:¬" -- Characters to visualize instead of whitespaces

vim.opt.completeopt = "menuone,noselect"

vim.opt.undodir = home .. "/.local/share/nvim/undo"
vim.opt.directory = home .. "/.local/share/nvim/swap"
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.shortmess:append "c"

vim.opt.confirm = true    -- Ask for some operations like quitting an unsaved file instead of failing
vim.opt.laststatus = 0    -- Hide status line
vim.opt.title = true      -- Allow neovim to set the window title
vim.opt.cmdheight = 1     -- Command line height
vim.opt.showtabline = 0   -- Hide tabline

vim.opt.cursorline = true -- Highlight current line

vim.opt.clipboard = "unnamedplus"

-- Keep cursor line only on focused window
local group = vim.api.nvim_create_augroup("CursorLineControl", { clear = true })
local set_cursorline = function(event, value, pattern)
    vim.api.nvim_create_autocmd(event, {
        group = group,
        pattern = pattern,
        callback = function()
            vim.opt_local.cursorline = value
        end,
    })
end
set_cursorline("WinLeave", false)
set_cursorline("WinEnter", true)
set_cursorline("FileType", false, "TelescopePrompt")

vim.opt.showmode = false

vim.opt.foldcolumn = "1"

vim.opt.fillchars = {
    eob = " ",
}

vim.cmd(":command! W w ++p")
vim.cmd(":command! Q q")
vim.cmd(":command! WQ wq")
vim.cmd(":command! Wq wq")

-- Custom stuff
vim.g.lsp_hints_enabled = false
