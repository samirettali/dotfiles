local function on_jump(_, bufnr)
	vim.diagnostic.open_float({
		bufnr = bufnr,
		scope = "cursor",
		focus = false,
		source = "if_many",
	})
end

vim.diagnostic.config({
	jump = { on_jump = on_jump },
	float = {
		header = "",
		scope = "cursor",
		source = "if_many",
	},
	virtual_lines = false,
	underline = true,
	severity_sort = true,
})

vim.keymap.set("n", "<leader>lq", vim.diagnostic.setqflist, { desc = "vim.diagnostic.setqflist()" })
vim.keymap.set("n", "<leader>lc", vim.diagnostic.setloclist, { desc = "vim.diagnostic.setloclist()" })

vim.keymap.set("n", "<leaver>tu", function()
	local config = not vim.diagnostic.config().underline
	vim.diagnostic.config({ underline = config })
end, { desc = "Toggle diagnostic underlines" })

vim.keymap.set("n", "<leader>tv", function()
	local config = not vim.diagnostic.config().virtual_lines
	vim.diagnostic.config({ virtual_lines = config })
end, { desc = "Toggle diagnostic virtual lines" })

-- TODO: remove
-- Override defaults with cursor centering
-- vim.keymap.set("n", "]d", function()
-- 	vim.diagnostic.jump({ count = vim.v.count1 })
-- 	vim.cmd("normal! zz")
-- end, { desc = "Jump to the next diagnostic in the current buffer" })
--
-- vim.keymap.set("n", "[d", function()
-- 	vim.diagnostic.jump({ count = -vim.v.count1 })
-- 	vim.cmd("normal! zz")
-- end, { desc = "Jump to the previous diagnostic in the current buffer" })
--
-- vim.keymap.set("n", "]D", function()
-- 	vim.diagnostic.jump({ count = vim._maxint, wrap = false })
-- 	vim.cmd("normal! zz")
-- end, { desc = "Jump to the last diagnostic in the current buffer" })
--
-- vim.keymap.set("n", "[D", function()
-- 	vim.diagnostic.jump({ count = -vim._maxint, wrap = false })
-- 	vim.cmd("normal! zz")
-- end, { desc = "Jump to the first diagnostic in the current buffer" })
