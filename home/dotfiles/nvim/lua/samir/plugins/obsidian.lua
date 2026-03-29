vim.pack.add({ "https://github.com/obsidian-nvim/obsidian.nvim" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.notify("Loading obsidian.nvim for markdown filetype", vim.log.levels.INFO)
		require("obsidian").setup({
			legacy_commands = false, -- this will be removed in the next major release
			templates = {
				folder = "Templates",
			},
			workspaces = {
				{
					name = "personal",
					path = "~/Documents/notes",
				},
			},
		})
	end,
})
