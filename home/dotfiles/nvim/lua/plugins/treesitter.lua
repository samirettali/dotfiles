return {
	"nvim-treesitter/nvim-treesitter",
	-- TODO: clone right version
	-- branch = "main",
	-- version = false,
	build = ":TSUpdate",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		local treesitter = require("nvim-treesitter.configs")
		local options = {
			ensure_installed = "all",
			auto_install = true,
			matchup = {
				enable = true,
			},
			highlight = {
				enable = true,
				disable = function(_, bufnr) -- Disable in files with more than 5K
					return vim.api.nvim_buf_line_count(bufnr) > 5000
				end,
			},
			autotag = {
				enable = true,
			},
			indent = {
				enable = true,
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<leader>vv",
					node_incremental = "+",
					scope_incremental = false,
					node_decremental = "_",
				},
			},
			context_commentstring = {
				enable = true,
			},
			textobjects = {
				select = {
					enable = true,
					lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
					keymaps = {
						-- You can use the capture groups defined in textobjects.scm
						["aa"] = { query = "@parameter.outer", desc = "around a parameter" },
						["ia"] = { query = "@parameter.inner", desc = "inside a parameter" },
						["af"] = { query = "@function.outer", desc = "around a function" },
						["if"] = { query = "@function.inner", desc = "inside a function" },
						["ac"] = { query = "@class.outer", desc = "around a class" },
						["ic"] = { query = "@class.inner", desc = "inside a class" },
						["al"] = { query = "@loop.outer", desc = "around a loop" },
						["il"] = { query = "@loop.inner", desc = "inside a loop" },
						["ai"] = { query = "@conditional.outer", desc = "around an if statement" },
						["ii"] = { query = "@conditional.inner", desc = "inside an if statement" },
						["at"] = { query = "@comment.outer", desc = "around a comment" }, -- TODO: can it be ac?
						["it"] = { query = "@comment.inner", desc = "around a comment" },
					},
				},
				move = {
					enable = false,
					set_jumps = true, -- Whether to set jumps in the jumplist
					-- TODO: remove if not needed
					-- goto_next_start = {
					-- 	["]m"] = "@function.outer",
					-- 	["]]"] = "@class.outer",
					-- },
					-- goto_next_end = {
					-- 	["]M"] = "@function.outer",
					-- 	["]["] = "@class.outer",
					-- },
					-- goto_previous_start = {
					-- 	["[m"] = "@function.outer",
					-- 	["[["] = "@class.outer",
					-- },
					-- goto_previous_end = {
					-- 	["[M"] = "@function.outer",
					-- 	["[]"] = "@class.outer",
					-- },
					goto_previous_start = {
						["[f"] = { query = "@function.outer", desc = "Previous function" },
						["[c"] = { query = "@class.outer", desc = "Previous class" },
						["[p"] = { query = "@parameter.inner", desc = "Previous parameter" },
					},
					goto_next_start = {
						["]f"] = { query = "@function.outer", desc = "Next function" },
						["]c"] = { query = "@class.outer", desc = "Next class" },
						["]p"] = { query = "@parameter.inner", desc = "Next parameter" },
					},
				},
				swap = {
					enable = true,
					swap_next = {
						["g>"] = { query = "@parameter.inner", desc = "Swap parameter with next" },
					},
					swap_previous = {
						["g<"] = { query = "@parameter.inner", desc = "Swap parameter with previous" },
					},
				},
			},
		}

		treesitter.setup(options)
	end,
}
