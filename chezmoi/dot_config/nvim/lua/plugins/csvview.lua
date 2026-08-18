vim.pack.add({ "https://github.com/hat0uma/csvview.nvim" })

require("csvview").setup({
	parser = {
		async_chunksize = 10,
	},
	view = {
		-- display_mode = "border",
	},
})
