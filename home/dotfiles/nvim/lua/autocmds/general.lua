local group = vim.api.nvim_create_augroup("General", { clear = true })

vim.api.nvim_create_autocmd("VimResized", {
	group = group,
	desc = "Automatically resize windows when terminal is resized",
	pattern = "*",
	-- command = "tabdo wincmd =", -- TODO: this leaves you in the last tab
	command = "wincmd =",
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight yanked text",
	group = group,
	callback = function()
		vim.hl.on_yank({ timeout = 100 })
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	group = group,
	desc = "Disable new line comments",
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
})


vim.api.nvim_create_autocmd("FileType", {
	group = group,
	desc = "Indent like the formatter: prettier and alejandra use 2 spaces",
	pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "jsonc", "css", "html", "nix" },
	callback = function()
		vim.bo.tabstop = 2
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	desc = "Indent like stylua: tabs",
	pattern = "lua",
	callback = function()
		vim.bo.expandtab = false
	end,
})
