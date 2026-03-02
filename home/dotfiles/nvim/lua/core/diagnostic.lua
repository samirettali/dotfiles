local function on_jump(_, bufnr)
	vim.diagnostic.open_float({
		bufnr = bufnr,
		scope = "cursor",
		focus = false,
		source = true,
	})
end

vim.diagnostic.config({
	float = {
		header = "",
		scope = "cursor",
		source = true,
	},
	virtual_lines = false,
	virtual_text = false,
	underline = true,
	severity_sort = true,
	jump = { on_jump = on_jump },
})

vim.keymap.set("n", "<leader>lq", vim.diagnostic.setqflist, { desc = "vim.diagnostic.setqflist()" })
vim.keymap.set("n", "<leader>lc", vim.diagnostic.setloclist, { desc = "vim.diagnostic.setloclist()" })

vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostic" })

vim.keymap.set("n", "<leader>tv", function()
	local config = not vim.diagnostic.config().virtual_lines
	vim.diagnostic.config({ virtual_lines = config })
end, { desc = "Toggle diagnostic virtual lines" })
