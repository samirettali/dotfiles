vim.api.nvim_create_autocmd("VimResized", {
	pattern = "*",
	desc = "Automatically resize windows when terminal is resized",
	command = "wincmd =",
})

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
	desc = "Return cursor to where it was last time closing the file",
	group = vim.api.nvim_create_augroup("CustomCursorPosition", { clear = true }),
	pattern = "*",
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			vim.api.nvim_win_set_cursor(0, mark)
		end
	end,
})

-- Create parent folder if it doesnt exist when saving a file
vim.api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
	pattern = "*",
	callback = function()
		local dir = vim.fn.expand("<afile>:p:h")
		if dir:match("^%a+://") == nil then
			vim.fn.mkdir(dir, "p")
		end
	end,
})

-- TODO: workaround until https://github.com/folke/lazy.nvim/issues/1951 is fixed
vim.api.nvim_create_autocmd("FileType", {
	desc = "User: fix backdrop for lazy window",
	pattern = "lazy_backdrop",
	group = vim.api.nvim_create_augroup("lazynvim-fix", { clear = true }),
	callback = function(ctx)
		local win = vim.fn.win_findbuf(ctx.buf)[1]
		vim.api.nvim_win_set_config(win, { border = "none" })
	end,
})
