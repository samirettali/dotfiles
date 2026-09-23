-- Installed but not loaded: its plugin/ file alone cost about 2ms on every start.
vim.pack.add({ "https://github.com/hat0uma/csvview.nvim" }, { load = function() end })

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "csv", "tsv" },
	once = true,
	callback = function()
		vim.cmd.packadd("csvview.nvim")
		require("csvview").setup({
			parser = {
				async_chunksize = 10,
			},
		})
	end,
})
