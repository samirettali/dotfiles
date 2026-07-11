vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- functions
function P(x)
	print(vim.inspect(x))
	return x
end

function N(x, level, opts)
	vim.notify(vim.inspect(x), level, opts)
	return x
end

require("plugins.nvim-treesitter")
require("plugins.nvim-treesitter-textobjects")
require("plugins.oil")
require("plugins.gitsigns")
require("plugins.moonfly")
require("plugins.nvim-web-devicons")

vim.cmd("packadd nvim.undotree") -- built in

vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.autoread = true
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.laststatus = 3
vim.opt.cmdheight = 1
vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "yes"
-- vim.opt.diffopt = "internal,filler,closeoff,algorithm:histogram,context:5,linematch:60" -- TODO: read docs
-- vim.opt.statusline = '[%n] %<%f %h%w%m%r%=%-14.(%l,%c%V%) %P' -- https://github.com/y9san9/y9san9.nvim/blob/main/init.lua
vim.opt.completeopt = {
	"menu",
	"menuone",
	"noselect",
	"noinsert",
	"fuzzy",
	"popup",
}
vim.opt.path:append("**")
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.grepprg = "rg --vimgrep"
vim.opt.shortmess:append("c")
vim.opt.shortmess:append("I")
vim.opt.fillchars = { eob = " " }
vim.opt.winborder = "rounded"
vim.opt.pumborder = "rounded"

require("ui.tabline")
require("autocmds")
require("plugins.nightfly")
require("plugins.auto-dark-mode")

-- diagnostic and lsp
vim.diagnostic.config({ signs = false })

vim.lsp.enable({
	"bashls",
	"clangd",
	"gopls",
	"golangci_lint_ls",
	"lua_ls",
	"stylua",
	"jsonls",
	"ts_ls", -- TODO: try vtsls
	"eslint",
	"nixd",
	"roslyn_ls",
	"rust_analyzer",
	"solidity_ls",
	"yamlls",
	"buf_ls",
	"copilot",
	"basedpyright",
	"ruff",
	"harper",
	"dartls",
})

-- plugins setup
require("plugins")

-- custom commands
vim.api.nvim_create_user_command("Grep", function(opts)
	-- TODO: args or fargs?
	local query = table.concat(opts.fargs, " ")
	vim.cmd("silent! grep! " .. query)
	vim.cmd("cwindow")
	vim.cmd("redraw!")
end, { nargs = "+", desc = "Run grep with the given query" })

-- keymaps
vim.keymap.set("n", "<leader>g", "<cmd>Grep <cword><cr>", { desc = "Grep word under cursor" })
vim.keymap.set("n", "<leader>lq", vim.diagnostic.setqflist, { desc = "vim.diagnostic.setqflist()" })
vim.keymap.set("n", "<leader>lc", vim.diagnostic.setloclist, { desc = "vim.diagnostic.setloclist()" })

-- nnoremap <silent><esc><esc> :nohlsearch<CR>
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })

vim.keymap.set("n", "<leader>ta", function()
	vim.lsp.enable("copilot", not vim.lsp.is_enabled("copilot"))
end, { desc = "Toggle copilot lsp" })

vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostic" })

vim.keymap.set("n", "<leader>tf", function()
	vim.g.disable_autoformat = not vim.g.disable_autoformat
end, { desc = "Toggle format on save" })

vim.keymap.set("n", "<leader>ti", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

vim.keymap.set("n", "<leader>tv", function()
	vim.diagnostic.config({
		virtual_lines = not vim.diagnostic.config().virtual_lines,
	})
end, { desc = "Toggle diagnostic virtual lines" })

----------------- yooooooooooo
-- vim.opt.wildmode = "noselect"
-- vim.api.nvim_create_autocmd("CmdlineChanged", {
-- 	pattern = ":",
-- 	callback = function()
-- 		vim.fn.wildtrigger()
-- 	end,
-- })

-- function _G.my_find(text, _)
-- 	local files = vim.fn.glob("**/*", true, true)
-- 	-- return { "%#DiagnosticError#" .. text .. "%*" .. "\t" .. "%#DiagnosticHint#" .. "in " .. files }
-- 	local result = vim.fn.matchfuzzy(files, text)
-- 	P(result)
-- 	return result
-- end
--
-- vim.opt.findfunc = "v:lua.my_find"

-------------------------------------

vim.api.nvim_create_user_command("Bufferize", function(opts)
	-- TODO: maybe make a version that takes a lua expression, evaluates it and prints it using vim.inspect
	local cmd = opts.args

	if cmd == "" then
		vim.notify("Please provide a Vim command to run", vim.log.levels.ERROR)
		return
	end

	local output = vim.fn.execute(cmd)

	local buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

	local bufname = ("[Vim Command Output]: %s"):format(cmd)
	vim.api.nvim_buf_set_name(buf, bufname)

	local lines = vim.split(output, "\n", { plain = true })
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

	vim.cmd("vsplit")
	vim.api.nvim_win_set_buf(0, buf)
end, {
	nargs = "+",
	complete = "command",
	desc = "Run a Vim command and show output in a new buffer",
})

vim.cmd(":command! E e")
vim.cmd(":command! W w")
vim.cmd(":command! Q q")
vim.cmd(":command! Wq wq")
vim.cmd(":command! WQ wq")
vim.cmd(":command! Qa qa")
vim.cmd(":command! QA qa")
vim.cmd(":command! Wa wa")
vim.cmd(":command! WA wa")
vim.cmd(":command! Wqa wqa")
vim.cmd(":command! WQa wqa")
vim.cmd(":command! WQA wqa")
vim.cmd(":command! Cq cq")
vim.cmd(":command! CQ cq")
