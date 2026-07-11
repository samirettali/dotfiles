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

require("options")

require("ui.tabline")
require("autocmds")
require("plugins.nightfly")
require("plugins.auto-dark-mode")

require("lsp")

-- plugins setup
require("plugins")

require("commands")

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
