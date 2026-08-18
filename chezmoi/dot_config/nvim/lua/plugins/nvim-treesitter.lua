vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = vim.treesitter.foldexpr
vim.opt.foldtext = ""
vim.opt.foldlevelstart = 99

require("nvim-treesitter").install("all")
require("autocmds.treesitter")
