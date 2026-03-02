vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- TODO: needed?
-- vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear hlsearch and ESC" })

vim.keymap.set("n", "<leader>q", function()
	local jumplist, _ = unpack(vim.fn.getjumplist())
	local qf_list = {}
	for _, v in pairs(jumplist) do
		if vim.fn.bufloaded(v.bufnr) == 1 then
			table.insert(qf_list, {
				bufnr = v.bufnr,
				lnum = v.lnum,
				col = v.col,
				text = vim.api.nvim_buf_get_lines(v.bufnr, v.lnum - 1, v.lnum, false)[1],
			})
		end
	end

	vim.fn.setqflist(qf_list, " ")
	vim.cmd("copen")
end, { desc = "Send jumplist to quickfix window" })
