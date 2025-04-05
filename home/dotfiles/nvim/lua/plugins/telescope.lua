local my_grep = function()
	local cword = vim.fn.expand("<cword>")
	require("telescope.builtin").live_grep({
		default_text = cword,
		on_complete = cword ~= ""
				and {
					function(picker)
						local mode = vim.fn.mode()
						local keys = mode ~= "n" and "<ESC>" or ""
						vim.api.nvim_feedkeys(
							vim.api.nvim_replace_termcodes(keys .. [[^v$<C-g>]], true, false, true),
							"n",
							true
						)
						-- should you have more callbacks, just pop the first one
						table.remove(picker._completion_callbacks, 1)
						-- copy mappings s.t. eg <C-n>, <C-p> works etc
						vim.tbl_map(function(mapping)
							vim.api.nvim_buf_set_keymap(0, "s", mapping.lhs, mapping.rhs, {})
						end, vim.api.nvim_buf_get_keymap(0, "i"))
					end,
				}
			or nil,
	})
end

return {
	{
		"Marskey/telescope-sg",
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
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
						i = { ["<esc>"] = require("telescope.actions").close },
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
					fzf = {},
					advanced_git_search = {},
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			}

			telescope.load_extension("ast_grep")
			telescope.load_extension("advanced_git_search")
			telescope.load_extension("fzf")
			telescope.load_extension("ui-select")

			local builtin = require("telescope.builtin")

			-- Telescope
			vim.keymap.set("n", "<leader>fh", builtin.help_tags)
			vim.keymap.set("n", "<C-f>", builtin.find_files)
			vim.keymap.set("n", "<C-g>", builtin.live_grep)
			vim.keymap.set("n", "<leader>fb", builtin.buffers)

			vim.keymap.set("n", "<leader>ps", function()
				builtin.grep_string({ search = vim.fn.input("grep: ") })
			end)

			vim.keymap.set("n", "<leader>pws", function()
				local word = vim.fn.expand("<cword>")
				builtin.grep_string({ search = word })
			end)

			vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols)
			vim.keymap.set("n", "<leader>ws", builtin.lsp_dynamic_workspace_symbols)
			vim.keymap.set("n", "gR", builtin.lsp_references)
			vim.keymap.set("n", "<leader>fh", builtin.help_tags)
			vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find)

			telescope.setup(options)
		end,
	},
}
