local home = os.getenv("HOME")

-- Tabs
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.shiftround = true -- Round indent
vim.opt.softtabstop = -1 -- use shiftwidth
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.cindent = true

vim.opt.breakindent = true
vim.opt.showbreak = "↳ "
vim.opt.linebreak = true

-- Case insensitive search unless \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Use undo files
vim.opt.undofile = true

-- Treat _ as a word separator
-- TODO: remove if not needed anymore
-- vim.opt.iskeyword = vim.opt.iskeyword - { "_" }

-- Show relative line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 4

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldcolumn = "0"
vim.opt.foldtext = "" -- Use syntax highlighting for the first line of the fold
vim.opt.foldlevel = 99
-- vim.opt.foldlevelstart = 2
-- vim.opt.foldnestmax = 4

vim.opt.timeoutlen = 300
vim.opt.updatetime = 250 -- Used for swapfile saving and CursorHold events

vim.opt.joinspaces = false -- No double spaces with join after a dot
vim.opt.scrolloff = 5 -- Lines of context
vim.opt.sidescrolloff = 5 -- Columns of context
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.pumheight = 15 -- Maximum of 15 elements shown in command auto completion
vim.opt.wildmode = "longest:full" -- Command-line completion mode
vim.opt.wildoptions = "pum" -- TODO: use blink.cmp?

vim.opt.showmatch = false -- Temporarily jump to matching parenthesis when inserting one, i kept this on for a bit but it's mostly distracting
vim.opt.lazyredraw = true -- Disable redrawing while running macros
vim.opt.inccommand = "nosplit" -- Show result of substitution as you type

vim.opt.mouse = "a"
vim.opt.mousemoveevent = true

vim.opt.listchars = {
	tab = "»·",
	trail = "·",
	nbsp = "~",
	eol = "¬",
}

vim.opt.completeopt = { "menu", "menuone", "noinsert", "fuzzy", "popup" }

vim.opt.winborder = "rounded"

vim.opt.undodir = home .. "/.local/share/nvim/undo"
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.shortmess:append("c")
vim.opt.shortmess:append("I") -- Hide intro message

vim.opt.confirm = true -- Ask for some operations like quitting an unsaved file instead of failing
vim.opt.title = true -- Allow neovim to set the window title

-- Hide everything
vim.opt.laststatus = 3
vim.opt.cmdheight = 0
vim.opt.signcolumn = "yes"

vim.opt.clipboard = "unnamedplus"

vim.opt.spelllang = "en" -- TODO: download italian dictionary

-- TODO: is this needed?
if os.getenv("SSH_TTY") and os.getenv("SSH_CLIENT") then
	local clipboard = require("vim.ui.clipboard.osc52")

	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = clipboard.copy("+"),
			["*"] = clipboard.copy("*"),
		},
		paste = {
			["+"] = clipboard.paste("+"),
			["*"] = clipboard.paste("*"),
		},
	}
end

vim.opt.showmode = false

vim.opt.cursorline = false

vim.opt.fillchars = {
	diff = "╱",
	horiz = "━",
	horizup = "┻",
	horizdown = "┳",
	vert = "┃",
	vertleft = "┫",
	vertright = "┣",
	verthoriz = "╋",
	eob = " ",
	fold = "─",
	foldopen = "▾",
	foldsep = " ",
	foldclose = "▸",
}

vim.opt.sessionoptions = {
	"buffers",
	"curdir",
	"folds",
	"help",
	"tabpages",
	"winsize",
	"globals",
}

vim.cmd(":command! E e")
vim.cmd(":command! W w")
vim.cmd(":command! Q q")
vim.cmd(":command! Wq wq")
vim.cmd(":command! WQ wq")
vim.cmd(":command! Qa qa")
vim.cmd(":command! QA qa")
vim.cmd(":command! Wa wa")
vim.cmd(":command! WA wa")

-- TODO
-- vim.cmd("syntax manual")
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "gitsendemail", "conf", "editorconfig", "qf", "checkhealth", "less" },
--   callback = function(event)
--     vim.bo[event.buf].syntax = vim.bo[event.buf].filetype
--   end,
-- })
