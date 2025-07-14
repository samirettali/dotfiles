return {
	-- TODO: cleanup
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	-- event = "VeryLazy", -- TODO: is this ok?
	---@type snacks.Config
	opts = {
		debug = {
			-- Add dd and bt functions to make debugging easier and replace vim.print
			enabled = true,
		},
		bigfile = {
			enabled = true,
		},
		explorer = {
			enabled = true,
		},
		input = {
			enabled = true,
		},
		notifier = {
			enabled = true,
		},
		picker = {
			enabled = true,
			matcher = {
				frecency = true,
			},
		},
		git = {
			enabled = true,
		},
		quickfile = {
			enabled = true,
		},
		scope = {
			enabled = false, -- TODO
		},
		statuscolumn = {
			enabled = true,
		},
		words = {
			enabled = true, -- TODO: enable navigation only
			debounce = 500, -- TODO: is there a way to remove the highlight immediately?
		},
	},
	keys = {
		{
			"<c-f>",
			function()
				local opts = {
					layout = {
						preset = "vscode",
					},
				}
				Snacks.picker.files(opts)
			end,
			desc = "Find Files",
		},
		{
			"<c-g>",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>sb",
			function()
				Snacks.picker.lines()
			end,
			desc = "Buffer Lines",
		},
		{
			"<localleader>fe",
			function()
				-- local opts = {
				-- 	auto_close = true,
				-- 	layout = {
				-- 		preset = "horizontal",
				-- 		preview = true,
				-- 	},
				-- }
				-- Snacks.explorer(opts)
				Snacks.explorer()
			end,
			desc = "File Explorer",
		},
		{
			"<leader>?",
			function()
				Snacks.picker.help()
			end,
			desc = "Help Pages",
		},
		{
			"<leader>sk",
			function()
				Snacks.picker.keymaps()
			end,
			desc = "Keymaps",
		},
		{
			"<leader>:",
			function()
				Snacks.picker.command_history()
			end,
			desc = "Command History",
		},
		{
			"<leader>/",
			function()
				Snacks.picker.search_history()
			end,
			desc = "Search History",
		},
		-- TODO: check the ones below
		{
			"<leader>sd",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "Diagnostics",
		},
		{
			"<leader>sD",
			function()
				Snacks.picker.diagnostics_buffer()
			end,
			desc = "Buffer Diagnostics",
		},
		{
			"<leader>n",
			function()
				Snacks.picker.notifications()
			end,
			desc = "Notification History",
		},
		-- find
		{
			"<leader>fg",
			function()
				Snacks.picker.git_files()
			end,
			desc = "Find Git Files",
		},
		{
			"<leader>gl",
			function()
				Snacks.picker.git_log()
			end,
			desc = "Git Log",
		},
		{
			"<leader>gL",
			function()
				Snacks.picker.git_log_line()
			end,
			desc = "Git Log Line",
		},
		{
			"<leader>gs",
			function()
				Snacks.picker.git_status()
			end,
			desc = "Git Status",
		},
		{
			"<leader>gd",
			function()
				Snacks.picker.git_diff()
			end,
			desc = "Git Diff (Hunks)",
		},
		{
			"<leader>gf",
			function()
				Snacks.picker.git_log_file()
			end,
			desc = "Git Log File",
		},
		-- Grep
		{
			"<leader>sw",
			function()
				Snacks.picker.grep_word()
			end,
			desc = "Visual selection or word",
			mode = { "n", "x" },
		},
		{
			"<leader>sm",
			function()
				Snacks.picker.marks()
			end,
			desc = "Marks",
		},
		{
			"<leader>sq",
			function()
				Snacks.picker.qflist()
			end,
			desc = "Quickfix List",
		},
		{
			"<leader>su",
			function()
				Snacks.picker.undo()
			end,
			desc = "Undo History",
		},
		{
			"<leader>sp",
			function()
				Snacks.picker()
			end,
			desc = "Snacks pickers",
		},
		-- LSP (using mostly the neovim ones for now)
		-- {
		-- 	"gd",
		-- 	function()
		-- 		Snacks.picker.lsp_definitions()
		-- 	end,
		-- 	desc = "Goto Definition",
		-- },
		-- {
		-- 	"gD",
		-- 	function()
		-- 		Snacks.picker.lsp_declarations()
		-- 	end,
		-- 	desc = "Goto Declaration",
		-- },
		-- {
		-- 	"gR",
		-- 	function()
		-- 		Snacks.picker.lsp_references()
		-- 	end,
		-- 	-- nowait = true,
		-- 	desc = "References",
		-- },
		-- {
		-- 	"gi",
		-- 	function()
		-- 		Snacks.picker.lsp_implementations()
		-- 	end,
		-- 	desc = "Goto Implementation",
		-- },
		-- {
		-- 	"gy", -- TODO "gT"?
		-- 	function()
		-- 		Snacks.picker.lsp_type_definitions()
		-- 	end,
		-- 	desc = "Goto T[y]pe Definition",
		-- },
		{
			"<localleader>ds",
			function()
				Snacks.picker.lsp_symbols()
			end,
			desc = "LSP Symbols",
		},
		{
			"<localleader>ws",
			function()
				Snacks.picker.lsp_workspace_symbols()
			end,
			desc = "LSP Workspace Symbols",
		},
		{
			"<leader>bd",
			function()
				Snacks.bufdelete()
			end,
			desc = "Delete buffers without disrupting window layout",
		},
		-- Other
		{
			"<leader>n",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Notification History",
		},
		{
			"<leader>cR",
			function()
				Snacks.rename.rename_file()
			end,
			desc = "Rename File",
		},
		{
			"<leader>gg",
			function()
				local opts = {
					configure = false,
				}
				Snacks.lazygit(opts)
			end,
			desc = "Lazygit",
		},
		{
			"<leader>un",
			function()
				Snacks.notifier.hide()
			end,
			desc = "Dismiss All Notifications",
		},
		{
			"]]",
			function()
				Snacks.words.jump(vim.v.count1)
			end,
			desc = "Next Reference",
			mode = { "n", "t" },
		},
		{
			"[[",
			function()
				Snacks.words.jump(-vim.v.count1)
			end,
			desc = "Prev Reference",
			mode = { "n", "t" },
		},
	},
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				-- Setup some globals for debugging (lazy-loaded)
				_G.dd = function(...)
					Snacks.debug.inspect(...)
				end
				_G.bt = function()
					Snacks.debug.backtrace()
				end
				vim.print = _G.dd -- Override print to use snacks for `:=` command

				-- Create some toggle mappings
				Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>ts")
				Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>tw")
				Snacks.toggle.option("list", { name = "List chars" }):map("<leader>tl")
				Snacks.toggle.inlay_hints():map("<leader>ti")
				Snacks.toggle.diagnostics():map("<leader>td")
				Snacks.toggle.line_number():map("<leader>tn")
				-- Snacks.toggle
				-- 	.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
				-- 	:map("<leader>uc")
				-- Snacks.toggle.treesitter():map("<leader>uT")
				-- Snacks.toggle
				-- 	.option("background", { off = "light", on = "dark", name = "Dark Background" })
				-- 	:map("<leader>ub")
				-- Snacks.toggle.indent():map("<leader>ug")
				-- Snacks.toggle.dim():map("<leader>uD")
			end,
		})
	end,
}
