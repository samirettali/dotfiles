vim.pack.add({ "https://github.com/obsidian-nvim/obsidian.nvim" })

local vault = vim.fn.expand("~/Documents/notes")

local group = vim.api.nvim_create_augroup("ObsidianVault", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
	group = group,
	pattern = vault .. "/*.md",
	callback = function()
		vim.api.nvim_clear_autocmds({ group = group })
		require("obsidian").setup({
			legacy_commands = false, -- this will be removed in the next major release
			templates = {
				folder = "Templates",
			},
			workspaces = {
				{
					name = "personal",
					path = vault,
				},
			},
		})
	end,
})
