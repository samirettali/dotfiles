vim.api.nvim_create_user_command("Bufferize", function(opts)
	-- TODO: maybe make a version that takes a lua expression, evaluates it and prints it using vim.inspect
	local cmd = opts.args

	if cmd == "" then
		vim.notify("Please provide a Vim command to run", vim.log.levels.ERROR)
		return
	end

	local output = vim.fn.execute(cmd)

	local buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "swapfile", false)
	vim.api.nvim_buf_set_option(buf, "modifiable", true)

	local bufname = ("[Vim Command Output]: %s"):format(cmd)
	vim.api.nvim_buf_set_name(buf, "[Vim Command Output]: " .. cmd)

	local lines = vim.split(output, "\n", { plain = true })
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	vim.api.nvim_buf_set_option(buf, "modifiable", false)

	vim.cmd("vsplit")
	vim.api.nvim_win_set_buf(0, buf)
end, {
	nargs = "+",
	complete = "command",
	desc = "Run a Vim command and show output in a new buffer",
})
