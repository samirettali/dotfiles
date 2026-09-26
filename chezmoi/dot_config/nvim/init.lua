vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- functions
function N(x, level, opts)
	vim.notify(vim.inspect(x), level, opts)
	return x
end

require("plugins.start")

vim.cmd("packadd nvim.undotree") -- built in
vim.cmd("packadd nvim.difftool") -- built in

require("options")

require("vim._core.ui2").enable({ msg = { targets = "msg" } })

require("ui.tabline")
require("autocmds")

require("lsp")

-- plugins setup
require("plugins")

require("commands")

require("keymaps")
