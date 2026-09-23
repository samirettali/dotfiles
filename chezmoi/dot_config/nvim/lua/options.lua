vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.laststatus = 3
vim.opt.clipboard = "unnamedplus"
if os.getenv("SSH_TTY") then
	vim.g.clipboard = "osc52"
end
vim.opt.signcolumn = "yes"
-- vim.opt.statusline = '[%n] %<%f %h%w%m%r%=%-14.(%l,%c%V%) %P' -- https://github.com/y9san9/y9san9.nvim/blob/main/init.lua
vim.opt.completeopt = {
	"menu",
	"menuone",
	"noselect",
	"fuzzy",
	"popup",
}
vim.opt.path:append("**")
vim.opt.wildmode = "longest:full,full"
vim.opt.grepprg = "rg --vimgrep"
vim.opt.shortmess:append("c")
vim.opt.shortmess:append("I")
vim.opt.fillchars = { eob = " " }
vim.opt.winborder = "rounded"
vim.opt.pumborder = "rounded"
