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

		-- TODO: try sqlfluff and sqlfmt
		formatters_by_ft = {
			cpp = {
				"clang-format",
			},
			cs = {
				"csharpier",
			},
			css = {
				"css_beautify",
			},
			go = {
				"goimports",
				"gofumpt",
			},
			javascript = {
				"prettierd",
			},
			lua = {
				"stylua",
			},
			nix = {
				"alejandra",
			},
			python = {
				"ruff_format",
				"ruff_fix",
				"ruff_organize_imports",
			},
			rust = {
				"rustfmt",
			},
			sh = {
				"shfmt",
			},
			toml = {
				"taplo",
			},
			typescript = {
				"prettierd",
			},
			wgsl = {
				"wgslfmt",
			},
			yaml = {
				"yamlfmt",
			},
			fish = {
				"fish_indent",
			},
			json = { "jq" },
			proto = { "buf" },
			-- ["*"] = { "codespell" }, -- TODO: this breaks some vim commands, e.g. window -> window
			["_"] = { "trim_whitespace" }, -- fallback,
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
			desc = "Toggle format on save",
		},
	},
}
