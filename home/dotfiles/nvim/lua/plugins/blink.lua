return {
	"saghen/blink.cmp",
	version = "*",
	event = "InsertEnter",
	dependencies = {
		"xzbdmw/colorful-menu.nvim",
		"rafamadriz/friendly-snippets",
	},
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		sources = {
			default = {
				"lsp",
				"path",
				"buffer",
				"snippets",
			},
		},
		signature = {
			enabled = true,
		},
		keymap = {
			preset = "none",
			["<c-n>"] = { "select_next", "show", "fallback_to_mappings" },
			["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide" },
			["<C-y>"] = { "select_and_accept" },

			-- TODO: map these to something
			-- ["<C-b>"] = { "scroll_documentation_up", "fallback" },
			-- ["<C-f>"] = { "scroll_documentation_down", "fallback" },

			-- ["<Tab>"] = { "snippet_forward", "fallback" },
			-- ["<S-Tab>"] = { "snippet_backward", "fallback" },
		},
		completion = {
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 500,
				update_delay_ms = 50,
			},
			list = {
				selection = {
					preselect = true,
					auto_insert = false,
				},
			},
			menu = {
				auto_show = true,
				draw = {
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind", gap = 1 },
						{ "source_name" },
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
						source_name = {
							width = { max = 30 },
							text = function(ctx)
								return "[" .. ctx.source_name .. "]"
							end,
							highlight = "BlinkCmpSource",
						},
					},
				},
			},
		},
	},
}
