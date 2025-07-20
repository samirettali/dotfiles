-- TODO: maybe show suggestions and hide them when cmp menu is show with
-- ```
-- vim.api.nvim_create_autocmd("User", {
--   pattern = "BlinkCmpMenuOpen",
--   callback = function()
--     vim.b.copilot_suggestion_hidden = true
--   end,
-- })
--
-- vim.api.nvim_create_autocmd("User", {
--   pattern = "BlinkCmpMenuClose",
--   callback = function()
--     vim.b.copilot_suggestion_hidden = false
--   end,
-- })
-- ```

local dependencies = {
	"xzbdmw/colorful-menu.nvim",
	"rafamadriz/friendly-snippets",
}
local use_copilot = false
local source

if use_copilot then
	source = "copilot"
	local copilot_deps = {
		"fang2hou/blink-copilot",
		{
			"zbirenbaum/copilot.lua",
			cmd = "Copilot",
			event = "InsertEnter",
			opts = {
				suggestion = { enabled = false },
				panel = { enabled = false },
				server = { type = "binary" },
				should_attach = function(_, bufname)
					if string.match(bufname, "env") then
						return false
					end

					return true
				end,
			},
		},
	}
	for _, v in ipairs(copilot_deps) do
		table.insert(dependencies, v)
	end
else
	-- TODO: this results as text and not supermaven
	source = "supermaven"
	local supermaven_deps = {
		{
			"supermaven-inc/supermaven-nvim",
			event = "InsertEnter",
			opts = {
				keymaps = {
					accept_suggestion = "<C-f>",
					clear_suggestion = "<C-]>",
					-- accept_word = "<c-j>",
				},
				disable_inline_completion = false,
				disable_keymaps = false,
				log_level = "off",
			},
		},
		"huijiro/blink-cmp-supermaven",
	}

	for _, v in ipairs(supermaven_deps) do
		table.insert(dependencies, v)
	end
end

return {
	"saghen/blink.cmp",
	version = "*",
	event = "InsertEnter", -- Using only insert enter allows blink to work also outside buffers and to not load it if a file is only opened
	dependencies = dependencies,
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		sources = {
			default = {
				"lsp",
				"path",
				"buffer",
				-- source,
				"snippets",
			},
			providers = {
				copilot = {
					name = "copilot",
					module = "blink-copilot",
					score_offset = 100,
					async = true,
				},
				supermaven = {
					name = "supermaven",
					module = "blink-cmp-supermaven",
					score_offset = 150,
					async = true,
				},
			},
		},
		appearance = {
			-- nerd_font_variant = "mono",
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
		fuzzy = {
			implementation = "prefer_rust_with_warning",
			max_typos = 5,
			use_frecency = true,
			use_proximity = true,
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
