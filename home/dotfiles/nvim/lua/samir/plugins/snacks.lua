vim.pack.add({ "https://github.com/folke/snacks.nvim" })
-- vim.cmd("packadd snacks.nvim")

require("snacks").setup({
	picker = { enabled = true },
	notifier = { enabled = true },
	bigfile = { enabled = true },
	input = { enabled = true },
	styles = {
		input = {
			relative = "cursor",
		},
	},
	lazygit = { enabled = true },
	-- dashboard = { enabled = true },
})

vim.keymap.set("n", "<c-f>", function()
	Snacks.picker.files({
		layout = {
			preview = false,
			layout = {
				max_width = 100,
				max_height = 20,
			},
		},
	})
end, { desc = "Snacks: files" })

vim.keymap.set("n", "<c-g>", function()
	Snacks.picker.grep({
		layout = {
			preview = false,
		},
	})
end, { desc = "Snacks: grep files" })

vim.keymap.set("n", "<leader>gd", function()
	Snacks.picker.git_diff()
end, { desc = "Snacks: git diff" })

vim.keymap.set("n", "<leader>fd", function()
	Snacks.picker.diagnostics()
end, { desc = "Snacks: diagnostics" })

vim.keymap.set("n", "<leader>fb", function()
	Snacks.picker.buffers()
end, { desc = "Snacks: buffers" })

vim.keymap.set("n", "<leader>fh", function()
	Snacks.picker.help()
end, { desc = "Snacks: help" })

vim.keymap.set("n", "<leader>fk", function()
	Snacks.picker.keymaps()
end, { desc = "Snacks: keymaps" })

vim.keymap.set("n", "gd", function()
	Snacks.picker.lsp_definitions()
end, { desc = "Snacks: LSP definitions" })

vim.keymap.set("n", "gri", function()
	Snacks.picker.lsp_implementations()
end, { desc = "Snacks: LSP implementations" })

vim.keymap.set("n", "grr", function()
	Snacks.picker.lsp_references()
end, { desc = "Snacks: LSP references" })

vim.keymap.set("n", "<leader>fq", function()
	Snacks.picker.qflist()
end, { desc = "Snacks: quickfix list" })

vim.keymap.set("n", "gO", function()
	Snacks.picker.lsp_symbols({
		layout = {
			preview = false,
		},
	})
end, { desc = "Snacks: LSP Symbols" })

vim.keymap.set("n", "<leader>fw", function()
	Snacks.picker.lsp_workspace_symbols()
end, { desc = "Snacks: LSP workspace symbols" })

vim.keymap.set("n", "<leader>fn", function()
	Snacks.picker.notifications()
end, { desc = "Snacks: notification history" })

vim.keymap.set("n", "<leader>ft", function()
	Snacks.picker.colorschemes()
end, { desc = "Snacks: colorschemes" })

vim.keymap.set("n", "<leader>fm", function()
	Snacks.picker.marks()
end, { desc = "Snacks: marks" })

vim.keymap.set("n", "<localleader>e", function()
	Snacks.picker.explorer({
		layout = {
			layout = {
				position = "right",
			},
		},
	})
end, { desc = "Snacks: explorer" })

-- vim.keymap.set("n", "<leader>ss", function()
-- 	Snacks.picker.actions.load_session()
-- end, { desc = "Snacks load session" })

---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
local progress = vim.defaulttable()
vim.api.nvim_create_autocmd("LspProgress", {
	---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
		if not client or type(value) ~= "table" then
			return
		end
		local p = progress[client.id]

		for i = 1, #p + 1 do
			if i == #p + 1 or p[i].token == ev.data.params.token then
				p[i] = {
					token = ev.data.params.token,
					msg = ("[%3d%%] %s%s"):format(
						value.kind == "end" and 100 or value.percentage or 100,
						value.title or "",
						value.message and (" **%s**"):format(value.message) or ""
					),
					done = value.kind == "end",
				}
				break
			end
		end

		local msg = {} ---@type string[]
		progress[client.id] = vim.tbl_filter(function(v)
			return table.insert(msg, v.msg) or not v.done
		end, p)

		local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
		vim.notify(table.concat(msg, "\n"), "info", {
			id = "lsp_progress",
			title = client.name,
			opts = function(notif)
				notif.icon = #progress[client.id] == 0 and " "
					or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
			end,
		})
	end,
})
