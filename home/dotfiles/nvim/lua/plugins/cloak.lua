return {
	-- Hide secrets in .env files
	-- TODO: add docker-compose.yml and Dockerfile
	"laytan/cloak.nvim",
	config = function()
		require("cloak").setup({
			patterns = {
				{
					file_pattern = { ".env*", "*.env*" },
					cloak_pattern = "=.+",
				},
			},
		})

		vim.keymap.set("n", "<leader>tc", "<cmd>CloakToggle<cr>", { silent = true })
	end,
}
