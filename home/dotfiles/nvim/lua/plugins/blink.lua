return {
	"saghen/blink.cmp",
	version = "*",
	dependencies = {
		"xzbdmw/colorful-menu.nvim",
	},
	opts = {
		sources = {
			default = { "lsp", "path", "buffer" }, -- "snippets"
		},
		signature = {
			enabled = true,
		},
		completion = {
			menu = {
				draw = {
					columns = {
						{ "kind_icon" },
						{ "label", gap = 1 },
					},
					components = {
						label = {
							text = function(ctx)
								return require("colorful-menu").blink_components_text(ctx)
							end,
							highlight = function(ctx)
								return require("colorful-menu").blink_components_highlight(ctx)
							end,
						},
					},
				},
			},
		},
	},
}
