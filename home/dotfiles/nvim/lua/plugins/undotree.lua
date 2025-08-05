return {
	"mbbill/undotree",
	event = "VeryLazy",
	config = function()
		vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { silent = true })
	end,
}
