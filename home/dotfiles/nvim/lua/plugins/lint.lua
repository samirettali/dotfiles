return {
	"mfussenegger/nvim-lint",
	config = function()
		local lint = require("lint")
		lint.linters_by_ft = {
			go = { "revive", "golangcilint" },
			javascript = { "eslint_d" },
			cpp = { "clang-tidy", "cppcheck", "cpplint" },
			bash = { "shellcheck" },
		}

		-- TODO: does this need an autogroup?
		-- TODO: should lint be required for each usage?
		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			pattern = { "*.go", "*.js", "*.cpp", ".sh" },
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
