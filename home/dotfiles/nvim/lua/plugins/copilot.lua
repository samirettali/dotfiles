if true then
	return {}
end

return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	opts = {
		suggestion = {
			enabled = true,
			auto_trigger = true,
			debounce = 0,
			hide_during_completion = false,
			keymap = {
				accept = "<c-f>",
			},
		},
		server = {
			type = "binary",
		},
	},
	keys = {
		{
			"<leader>ts",
			function()
				local client = require("copilot.client")
				if client.is_disabled() then
					require("copilot.command").enable()
					vim.notify("Copilot enabled", vim.log.levels.INFO)
				else
					require("copilot.command").disable()
					vim.notify("Copilot disabled", vim.log.levels.INFO)
				end
			end,
			desc = "Toggle Copilot",
		},
	},
}
