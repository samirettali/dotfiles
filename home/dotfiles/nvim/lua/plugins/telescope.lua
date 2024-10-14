return {
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
		},
	},
	{
		"Marskey/telescope-sg",
	},
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
		config = function()
			require("telescope").load_extension("fzf")
		end,
	},
	{
		"nvim-telescope/telescope-frecency.nvim",
		config = function()
			require("telescope").load_extension("frecency")
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
		},
		config = function()
			local telescope = require("telescope")

			local options = {
				defaults = {
					file_ignore_patterns = {
						"^node_modules/",
						"^vendor/",
						"^contracts/mocks/",
						"^.git/",
						"^.cache/",
						"%.mmdb",
						"%.pdf",
						"%.zip",
						"%.dll",
					},
					mappings = {
						n = { ["q"] = require("telescope.actions").close },
					},
				},
				pickers = {
					find_files = {
						theme = "dropdown",
						previewer = false,
					},
					git_files = {
						theme = "dropdown",
						previewer = false,
					},
					grep_files = {
						theme = "dropdown",
					},
				},
				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
					},
					file_browser = {
						theme = "dropdown",
						previewer = false,
					},
					advanced_git_search = {},
				},
			}

			telescope.load_extension("file_browser")
			telescope.load_extension("ast_grep")
			telescope.load_extension("advanced_git_search")
			telescope.load_extension("ui-select")

			local builtin = require("telescope.builtin")

			-- Telescope
			vim.keymap.set("n", "<C-f>", builtin.find_files)
			vim.keymap.set("n", "<C-g>", builtin.live_grep)
			vim.keymap.set("n", "<leader>b", builtin.buffers)

			vim.keymap.set("n", "<leader>ps", function()
				builtin.grep_string({ search = vim.fn.input("grep: ") })
			end)

			vim.keymap.set("n", "<leader>pws", function()
				local word = vim.fn.expand("<cword>")
				builtin.grep_string({ search = word })
			end)

			vim.keymap.set("n", "<C-s>", builtin.lsp_document_symbols)
			vim.keymap.set("n", "gR", builtin.lsp_references)
			vim.keymap.set("n", "<leader>fh", builtin.help_tags)
			vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find)

			telescope.setup(options)
		end,
	},
}
