return {
	-- Hide secrets in .env files
	"laytan/cloak.nvim",
	config = function()
		vim.keymap.set("n", "<leader>tc", "<cmd>CloakToggle<cr>", { noremap = true, silent = true })
	end,
}
