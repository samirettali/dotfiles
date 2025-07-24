if true then
	return {}
end

return {
	"Bekaboo/dropbar.nvim",
	-- TODO: lazy loading might not be needed as the plugin already uses and autocmd
	-- https://github.com/Bekaboo/dropbar.nvim/blob/master/plugin/dropbar.lua
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local dropbar_api = require("dropbar.api")
		vim.keymap.set("n", "<localleader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
		vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
		vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
		vim.ui.select = require("dropbar.utils.menu").select
	end,
}
