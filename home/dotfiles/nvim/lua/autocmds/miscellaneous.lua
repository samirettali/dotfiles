vim.api.nvim_create_autocmd({ "TermRequest", "ModeChanged" }, {
	desc = "Refresh tabline",
	callback = function()
		vim.cmd.redrawtabline()
	end,
})
