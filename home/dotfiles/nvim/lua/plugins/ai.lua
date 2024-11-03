return {
	-- {
	-- 	"Exafunction/codeium.vim",
	-- 	event = "BufEnter",
	-- },
	{
		"monkoose/neocodeium",
		event = "VeryLazy",
		config = function()
			local neocodeium = require("neocodeium")

			local opts = {
				show_label = false,
			}

			neocodeium.setup(opts)

			vim.keymap.set("i", "<C-f>", function()
				neocodeium.accept()
			end)
			vim.keymap.set("i", "<C-e>", function()
				neocodeium.cycle_or_complete()
			end)
			vim.keymap.set("i", "<C-y>", function()
				neocodeium.cycle_or_complete(-1)
			end)

			vim.keymap.set("i", "<C-c>", function()
				require("neocodeium").clear()
			end)
		end,
	},
	-- {
	-- 	"supermaven-inc/supermaven-nvim",
	-- 	opts = { log_level = "off" },
	-- },
	{
		-- views can only be fully collapsed with the global statusline
		-- vim.opt.laststatus = 3
		-- Default splitting will cause your main splits to jump when opening an edgebar.
		-- To prevent this, set `splitkeep` to either `screen` or `topline`.
		-- vim.opt.splitkeep = "screen"
		"yetone/avante.nvim",
		event = "VeryLazy",
		build = "make",
		dependencies = {
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below is optional, make sure to setup it properly if you have lazy=true
			{
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
					heading = {
						enabled = false,
						sign = false,
					},
				},
				ft = { "markdown", "Avante" },
			},
		},
		opts = {
			vendors = {
				ollama = {
					["local"] = true,
					endpoint = "127.0.0.1:11434/v1",
					model = "codegemma",
					parse_curl_args = function(opts, code_opts)
						return {
							url = opts.endpoint .. "/chat/completions",
							headers = {
								["Accept"] = "application/json",
								["Content-Type"] = "application/json",
							},
							body = {
								model = opts.model,
								messages = require("avante.providers").copilot.parse_message(code_opts), -- you can make your own message, but this is very advanced
								max_tokens = 2048,
								stream = true,
							},
						}
					end,
					parse_response_data = function(data_stream, event_state, opts)
						require("avante.providers").openai.parse_response(data_stream, event_state, opts)
					end,
				},
			},
		},
	},
}
