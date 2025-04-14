return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
			"leoluz/nvim-dap-go",
			"theHamsta/nvim-dap-virtual-text",
			{
				"igorlfs/nvim-dap-view",
				opts = {
					windows = {
						terminal = {
							hide = { "go" },
						},
					},
				},
			},
		},
		config = function()
			local dap = require("dap")
			local dapgo = require("dap-go")

			dapgo.setup()
			require("nvim-dap-virtual-text").setup({})

			vim.keymap.set("n", "<leader>dd", dapgo.debug_test, { desc = "debug: debug test" })

			vim.keymap.set("n", "<F1>", dap.step_over)
			vim.keymap.set("n", "<F2>", dap.step_into)
			vim.keymap.set("n", "<F3>", dap.step_out)
			vim.keymap.set("n", "<F4>", dap.step_back)
			vim.keymap.set("n", "<F5>", dap.continue)
			vim.keymap.set("n", "<F12>", dap.restart)

			vim.keymap.set("n", "<leader>gb", dap.run_to_cursor)
			vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "debug: toggle breakpoint" })
			vim.keymap.set("n", "<leader>B", function()
				dap.set_breakpoint(vim.fn.input("breakpoint condition: "))
			end, { desc = "debug: set conditional breakpoint" })

			local dv = require("dap-view")
			dap.listeners.before.attach["dap-view-config"] = function()
				dv.open()
			end
			dap.listeners.before.launch["dap-view-config"] = function()
				dv.open()
			end
			dap.listeners.before.event_terminated["dap-view-config"] = function()
				dv.close()
			end
			dap.listeners.before.event_exited["dap-view-config"] = function()
				dv.close()
			end
		end,
	},
}
