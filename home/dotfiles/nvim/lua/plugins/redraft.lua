vim.api.nvim_create_autocmd("PackChanged", {
	group = vim.api.nvim_create_augroup("RedraftPackChanged", { clear = true }),
	callback = function(ev)
		P(ev)
		vim.notify(ev.data.spec.name .. " has been updated.")
		if ev.data.spec.name == "nvim-redraft" and ev.data.kind ~= "deleted" then
			local cmd = string.format("cd %s/ts && npm install && npm run build", ev.data.path)
			vim.fn.system(cmd)
		end
	end,
})

vim.pack.add({
	{ src = "https://github.com/samirettali/nvim-redraft", version = "fix-multiple-edits" },
	{ src = "https://github.com/zbirenbaum/copilot.lua" },
})

require("copilot").setup({ enabled = false, suggestion = { enabled = false } })
require("nvim-redraft").setup({
	llm = {
		models = {
			{
				provider = "copilot",
				model = "claude-sonnet-4.6",
			},
		},
	},
	diff_mode = true,
	keys = {},
	input = {
		icon = "",
		prompt = "Edit",
	},
})

vim.keymap.set("v", "<leader>ae", function()
	require("nvim-redraft").edit()
end, { desc = "AI Edit Selection" })

vim.keymap.set("n", "<leader>am", function()
	require("nvim-redraft").select_model()
end, { desc = "AI Edit Selection" })
