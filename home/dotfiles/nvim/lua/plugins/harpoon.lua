return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	event = "VeryLazy",
	config = function()
		local harpoon = require("harpoon")

		harpoon:setup()

		vim.keymap.set("n", "<leader>ha", function()
			harpoon:list():add()
		end, { desc = "Harpoon: add file" })
		vim.keymap.set("n", "<leader>he", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon: open quick menu" })

		vim.keymap.set("n", "<leader>gh", function()
			harpoon:list():select(1)
		end, { desc = "Harpoon: go to first file" })
		vim.keymap.set("n", "<leader>gj", function()
			harpoon:list():select(2)
		end, { desc = "Harpoon: go to second file" })
		vim.keymap.set("n", "<leader>gk", function()
			harpoon:list():select(3)
		end, { desc = "Harpoon: go to third file" })
		vim.keymap.set("n", "<leader>gl", function()
			harpoon:list():select(4)
		end, { desc = "Harpoon: go to fourth file" })
	end,
}
