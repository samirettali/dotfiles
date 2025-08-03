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
	},
}
