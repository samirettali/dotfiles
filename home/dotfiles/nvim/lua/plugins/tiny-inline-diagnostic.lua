return {
	"rachartier/tiny-inline-diagnostic.nvim",
	event = "LspAttach",
	opts = {
		preset = "modern",
		transparent_bg = false,
		options = {
			use_icons_from_diagnostic = false,
			add_messages = {
				messages = true,
				display_count = true,
				-- use_max_severity = false, -- When counting, only show the most severe diagnostic
				-- show_multiple_glyphs = true, -- Show multiple icons for multiple diagnostics of same severity
			},
			show_source = {
				enabled = true,
				if_many = false,
			},
			multilines = {
				enabled = true,
				always_show = true,
			},
		},
	},
}
