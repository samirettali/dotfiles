vim.pack.add({ "https://github.com/zbirenbaum/copilot.lua" })

require("copilot").setup({
	enabled = false,
	suggestion = {
		enabled = false,
	},
	nes = {
		enabled = true,
		keymap = {
			accept_and_goto = "<leader>p",
			accept = false,
			dismiss = "<Esc>",
		},
	},
})
