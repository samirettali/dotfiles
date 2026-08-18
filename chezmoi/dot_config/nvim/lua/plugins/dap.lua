vim.pack.add({
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/nvim-neotest/nvim-nio",
	"https://github.com/leoluz/nvim-dap-go",
	"https://github.com/mfussenegger/nvim-dap-python",
	"https://github.com/NicholasMata/nvim-dap-cs",
	-- "https://github.com/theHamsta/nvim-dap-virtual-text",
	"https://github.com/igorlfs/nvim-dap-view",
})

-- vim.cmd("packadd nvim-dap")
-- vim.cmd("packadd nvim-nio")
-- vim.cmd("packadd nvim-dap-go")
-- vim.cmd("packadd nvim-dap-python")
-- vim.cmd("packadd nvim-dap-cs")
-- -- vim.cmd("packadd nvim-dap-virtual-text")
-- vim.cmd("packadd nvim-dap-view")

local fts = {
	"go",
	"cs",
	"python",
}

require("dap-view").setup({
	windows = {
		-- position = "right",
		terminal = {
			hide = { "go", "cs", "python", "py" },
		},
	},
	winbar = {
		show = true,
		controls = { enabled = true },
	},
})

local keys = {
	{
		"<leader>tb",
		function()
			require("dap").toggle_breakpoint()
		end,
		desc = "DAP: toggle breakpoint",
		ft = fts,
	},
	{
		"<leader>tB",
		function()
			require("dap").set_breakpoint(vim.fn.input("breakpoint condition: "))
		end,
		desc = "DAP: set conditional breakpoint",
		ft = fts,
	},
	-- {
	-- 	"f5",
	-- 	function()
	-- 		require("dap").continue()
	-- 	end,
	-- 	desc = "DAP: continue",
	-- 	ft = fts,
	-- },
	{
		"<Right>",
		function()
			require("dap").step_over()
		end,
		desc = "DAP: step over",
		ft = fts,
	},
	{
		"<Down>",
		function()
			require("dap").step_into()
		end,
		desc = "DAP: step into",
		ft = fts,
	},
	{
		"<Up>",
		function()
			require("dap").step_out()
		end,
		desc = "DAP: step out",
		ft = fts,
	},
	{
		"<leader>gc",
		function()
			require("dap").run_to_cursor()
		end,
		desc = "DAP: run to cursor",
		ft = fts,
	},
	{
		"<leader>dd",
		function()
			require("dap-go").debug_test()
		end,
		desc = "DAP: debug test",
	},
}

for _, key in ipairs(keys) do
	vim.keymap.set("n", key[1], key[2], { desc = key.desc })
end

local dap = require("dap")

-- require("nvim-dap-virtual-text").setup({})
require("dap-go").setup()
require("dap-cs").setup()
require("dap-python").setup("python3")

local dv = require("dap-view")

-- Store original 'o' keymap
local original_o_keymap = nil

dap.listeners.before.attach["dap-view-config"] = function()
	dv.open()
	-- 	-- Store and override 'o' keymap
	-- 	original_o_keymap = vim.fn.maparg("o", "n", false, true)
	-- 	vim.keymap.set("n", "o", dap.step_over, { desc = "debug: step over" })
end

dap.listeners.before.launch["dap-view-config"] = function()
	dv.open()
	-- 	-- Store and override 'o' keymap
	-- 	original_o_keymap = vim.fn.maparg("o", "n", false, true)
	-- 	vim.keymap.set("n", "o", dap.step_over, { desc = "debug: step over" })
end

dap.listeners.before.event_terminated["dap-view-config"] = function()
	dv.close()
	-- 	-- Restore original 'o' keymap
	-- 	pcall(function()
	-- 		vim.keymap.del("n", "o")
	-- 	end)
	-- 	if original_o_keymap and original_o_keymap.rhs then
	-- 		vim.keymap.set("n", "o", original_o_keymap.rhs, {
	-- 			desc = original_o_keymap.desc,
	-- 			silent = original_o_keymap.silent == 1,
	-- 			expr = original_o_keymap.expr == 1,
	-- 			noremap = original_o_keymap.noremap == 1,
	-- 		})
	-- 	end
end

dap.listeners.before.event_exited["dap-view-config"] = function()
	dv.close()
	-- 	-- Restore original 'o' keymap
	-- 	pcall(function()
	-- 		vim.keymap.del("n", "o")
	-- 	end)
	-- 	if original_o_keymap and original_o_keymap.rhs then
	-- 		vim.keymap.set("n", "o", original_o_keymap.rhs, {
	-- 			desc = original_o_keymap.desc,
	-- 			silent = original_o_keymap.silent == 1,
	-- 			expr = original_o_keymap.expr == 1,
	-- 			noremap = original_o_keymap.noremap == 1,
	-- 		})
	-- 	end
end

-- {
-- 	"kndndrj/nvim-projector",
-- 	dependencies = {
-- 		-- required:
-- 		"MunifTanjim/nui.nvim",
-- 		-- optional extensions:
-- 		"kndndrj/projector-neotest",
-- 		-- dependencies of extensions:
-- 		"nvim-neotest/neotest",
-- 	},
-- 	config = function()
-- 		require("projector").setup(--[[optional config]])
-- 	end,
-- },
-- cmd = {
-- 	"DapContinue",
-- },
-- dependencies = {
-- 	"nvim-neotest/nvim-nio",
-- 	"leoluz/nvim-dap-go",
-- 	{ "mfussenegger/nvim-dap-python" },
-- 	{ "NicholasMata/nvim-dap-cs" },
-- 	"theHamsta/nvim-dap-virtual-text",
-- 	{
