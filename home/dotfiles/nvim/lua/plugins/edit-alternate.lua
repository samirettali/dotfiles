return {
	"tjdevries/edit_alternate.vim",
	dependencies = { "tjdevries/standard.vim", "tjdevries/conf.vim" },
	config = function()
		vim.fn["edit_alternate#rule#add"]("go", function(filename)
			if filename:find("_test.go") then
				return (filename:gsub("_test%.go", ".go"))
			else
				return (filename:gsub("%.go", "_test.go"))
			end
		end)

		vim.api.nvim_set_keymap("n", "<leader><leader>", "<cmd>EditAlternate<CR>", { silent = true })
	end,
}
