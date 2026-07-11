vim.api.nvim_create_autocmd("VimResized", {
	desc = "Automatically resize windows when terminal is resized",
	pattern = "*",
	-- command = "tabdo wincmd =", -- TODO: this leaves you in the last tab
	command = "wincmd =",
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight yanked text",
	group = vim.api.nvim_create_augroup("HighlightYankedText", { clear = true }),
	callback = function()
		vim.hl.on_yank({ timeout = 100 })
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	desc = "Disable new line comments",
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
})

