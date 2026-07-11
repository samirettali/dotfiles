local group = vim.api.nvim_create_augroup("Miscellaneous", { clear = true })

vim.api.nvim_create_autocmd({ "TermRequest", "ModeChanged" }, {
	group = group,
	desc = "Refresh tabline",
	callback = function()
		vim.cmd.redrawtabline()
	end,
})
