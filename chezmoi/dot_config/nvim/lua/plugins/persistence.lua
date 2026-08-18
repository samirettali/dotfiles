vim.pack.add({ "https://github.com/folke/persistence.nvim" })

-- vim.cmd("packadd persistence.nvim")

require("persistence").setup({
	dir = vim.fn.stdpath("state") .. "/sessions/",
	need = 1,
	branch = true,
})

-- Not the "persistence" group: that name belongs to the plugin's own
-- VimLeavePre autosave, and clearing it would stop sessions being saved.
local group = vim.api.nvim_create_augroup("persistence_autoload", { clear = true })

-- Reading from stdin creates a buffer, so the session must not replace it.
vim.api.nvim_create_autocmd("StdinReadPre", {
	group = group,
	callback = function()
		vim.g.started_with_stdin = true
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	group = group,
	nested = true,
	callback = function()
		if vim.fn.argc(-1) ~= 0 or vim.g.started_with_stdin then
			return
		end
		require("persistence").load()
	end,
})

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
