return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	cmd = "ConformInfo",
	opts = {
		format_after_save = function()
			if vim.g.disable_autoformat then
				return
			end

			return { timeout_ms = 3000, lsp_format = "fallback" }
		end,

		formatters_by_ft = {
			cpp = { "clang-format" },
			cs = { "csharpier" },
			css = { "css_beautify" },
			go = { "goimports", "gofumpt" },
			javascript = { "prettierd", "prettier", stop_after_first = true },
			lua = { "stylua" },
			nix = { "alejandra" },
			python = { "ruff" },
			rust = { "rustfmt" },
			sh = { "shfmt" },
			toml = { "taplo" },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			wgsl = { "wgslfmt" },
			yaml = { "yamlfmt" },
			-- ["*"] = { "codespell" }, -- TODO: this breaks some vim commands, e.g. windo -> window
			["_"] = { "trim_whitespace" }, -- fallback
		},
		-- formatters = {
		-- 	shfmt = {
		-- 		prepend_args = { "-i", "2" },
		-- 	},
		-- },
	},
	keys = {
		{
			"<leader>tf",
			function()
				vim.g.disable_autoformat = not vim.g.disable_autoformat

				if vim.g.disable_autoformat then
					vim.notify("Format on save disabled")
				else
					vim.notify("Format on save enabled")
				end
			end,
			"n",
			desc = "Toggle format on save",
		},
	},
}
