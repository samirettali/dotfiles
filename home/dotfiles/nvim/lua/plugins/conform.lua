return {
	"stevearc/conform.nvim",
	opts = {
		format_on_save = {
			timeout_ms = 3000,
			lsp_format = "fallback",
		},
		formatters_by_ft = {
			lua = { "stylua" },
			go = { "goimports", "gofumpt" },
			rust = { "rustfmt" },
			nix = { "alejandra" },
			bash = { "shellcheck" },
			javascript = { "prettierd" },
			python = { "isort", "black" },
			ocaml = { "ocamlformat" },
			cpp = { "clang-format" },
			cs = { "csharpier" },
			["*"] = { "codespell" },
			["_"] = { "trim_whitespace" }, -- if no formatter is found, use this
		},
	},
}
