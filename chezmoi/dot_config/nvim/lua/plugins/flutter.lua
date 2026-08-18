vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-flutter/flutter-tools.nvim",
})

require("flutter-tools").setup({
	ui = {
		border = "rounded",
		notification_style = "native",
	},
	debugger = {
		enabled = true,
		exception_breakpoints = {},
		evaluate_to_string_in_debug_views = true,
	},
	dev_log = {
		enabled = true,
		notify_errors = true,
		open_cmd = "15split",
		focus_on_open = false,
	},
	dev_tools = {
		autostart = false,
		auto_open_browser = false,
	},
	outline = {
		open_cmd = "30vnew",
		auto_open = false,
	},
	closing_tags = {
		enabled = true,
		prefix = "> ",
	},
	lsp = {
		settings = {
			showTodos = true,
			completeFunctionCalls = true,
			enableSnippets = true,
			updateImportsOnRename = true,
			renameFilesWithClasses = "prompt",
		},
	},
})

local flutter_keymaps = {
	{ "<localleader>fr", "<cmd>FlutterRun<cr>", "Flutter: run" },
	{ "<localleader>fd", "<cmd>FlutterDevices<cr>", "Flutter: select device" },
	{ "<localleader>fe", "<cmd>FlutterEmulators<cr>", "Flutter: select emulator" },
	{ "<localleader>fl", "<cmd>FlutterReload<cr>", "Flutter: hot reload" },
	{ "<localleader>fR", "<cmd>FlutterRestart<cr>", "Flutter: hot restart" },
	{ "<localleader>fq", "<cmd>FlutterQuit<cr>", "Flutter: quit" },
	{ "<localleader>fo", "<cmd>FlutterOutlineToggle<cr>", "Flutter: toggle outline" },
	{ "<localleader>fL", "<cmd>FlutterLogToggle<cr>", "Flutter: toggle log" },
	{ "<localleader>fp", "<cmd>FlutterPubGet<cr>", "Flutter: pub get" },
	{ "<localleader>ft", "<cmd>FlutterDevTools<cr>", "Flutter: start DevTools" },
}

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("FlutterKeymaps", { clear = true }),
	pattern = "dart",
	callback = function(args)
		for _, keymap in ipairs(flutter_keymaps) do
			vim.keymap.set("n", keymap[1], keymap[2], {
				buffer = args.buf,
				desc = keymap[3],
				silent = true,
			})
		end
	end,
})
