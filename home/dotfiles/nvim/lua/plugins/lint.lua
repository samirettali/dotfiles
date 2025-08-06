return {
	"mfussenegger/nvim-lint",
	event = { "BufWritePost", "BufReadPost", "InsertLeave" },
	config = function()
		local lint = require("lint")
		lint.linters_by_ft = {
			go = { "revive", "golangcilint" },
			javascript = { "eslint_d" },
			cpp = { "clang-tidy", "cppcheck", "cpplint" },
			bash = { "shellcheck" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("linting", { clear = true })
		vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
