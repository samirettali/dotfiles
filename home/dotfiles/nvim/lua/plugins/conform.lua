return {
	"stevearc/conform.nvim",

	config = function()
		local opts = {
			format_after_save = function()
				if vim.g.disable_autoformat then
					return
				end

				return { timeout_ms = 3000, lsp_format = "fallback" }
			end,

			formatters_by_ft = {
				lua = { "stylua" },
				go = { "goimports", "gofumpt" },
				rust = { "rustfmt" },
				nix = { "alejandra" },
				javascript = { "prettierd" },
				python = { "ruff" },
				ocaml = { "ocamlformat" },
				cpp = { "clang-format" },
				cs = { "csharpier" },
				yaml = { "yamlfmt" },
				["*"] = { "codespell" },
				["_"] = { "trim_whitespace" }, -- fallback
			},
		}

		local conform = require("conform")
		conform.setup(opts)

		vim.keymap.set("n", "<leader>tf", function()
			vim.g.disable_autoformat = not vim.g.disable_autoformat

			if vim.g.disable_autoformat then
				vim.notify("Formatting disabled")
			else
				vim.notify("Formatting enabled")
			end
		end, { desc = "Toggle format on save" })
	end,
}
