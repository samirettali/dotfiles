vim.pack.add({ "https://github.com/aznhe21/actions-preview.nvim" })

-- vim.cmd("packadd actions-preview.nvim")

require("actions-preview").setup({
	preview = {
		border = "rounded",
	},
})

vim.keymap.set("n", "gra", function()
	require("actions-preview").code_actions()
end, { desc = "Actions Preview: code actions" })
