vim.pack.add({ "https://github.com/folke/persistence.nvim" })

-- vim.cmd("packadd persistence.nvim")

require("persistence").setup({
	dir = vim.fn.stdpath("state") .. "/sessions/",
	need = 1,
	branch = true,
})

-- vim.api.nvim_create_autocmd("VimEnter", {
-- 	group = vim.api.nvim_create_augroup("persistence", { clear = true }),
-- 	callback = function()
-- 		if vim.fn.argc() ~= 0 or vim.g.started_with_stdin then
-- 			return
-- 		end
-- 		local sessions = require("persistence").list()
-- 		vim.notify("sessions: " .. vim.inspect(sessions))
-- 		require("persistence").load()
-- 		vim.notify("persistence loaded")
-- 	end,
-- 	nested = true,
-- })

-- select a session to load
vim.keymap.set("n", "<leader>sc", function()
	require("persistence").select()
end)

vim.keymap.set("n", "<leader>sl", function()
	require("persistence").load()
end)

-- select a session to load
vim.keymap.set("n", "<leader>ss", function()
	require("persistence").save()
end)
