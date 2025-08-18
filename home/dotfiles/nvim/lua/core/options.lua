vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.opt.linebreak = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.undofile = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.laststatus = 3
vim.opt.cmdheight = 0

vim.opt.winborder = "rounded"

vim.opt.clipboard = "unnamedplus"

vim.opt.diffopt = "internal,filler,closeoff,linematch:60"
vim.opt.conceallevel = 2

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldnestmax = 4

vim.opt.completeopt = {
	"menu",
	"menuone",
	"noselect",
	"noinsert",
	"fuzzy",
}

vim.opt.shortmess:append("c")
vim.opt.shortmess:append("I")

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

vim.opt.listchars = {
	tab = "»·",
	trail = "·",
	nbsp = "~",
	eol = "¬",
}

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

vim.opt.showbreak = "↳ "
