local M = {}

M.is_empty = function(s)
	return s == nil or s == ""
end

M.plugin_filetypes = {
	"alpha",
	"dashboard",
	"help",
	"lazy",
	"lir",
	"mason",
	"neogitstatus",
	"neo-tree",
	"netrw",
	"NvimTree",
	"oil",
	"Outline",
	"packer",
	"qf",
	"spectre_panel",
	"startify",
	"TelescopePrompt",
	"toggleterm",
	"Trouble",
	"vista_kind",
}

M.is_plugin_filetype = function()
	if vim.tbl_contains(M.plugin_filetypes, vim.bo.filetype) then
		return true
	end
	return false
end

M.has_value = function(tab, val)
	if tab == nil then
		return false
	end

	for _, value in ipairs(tab) do
		-- We grab the first index of our sub-table instead
		if value == val then
			return true
		end
	end

	return false
end

M.get_parent_folder = function()
	local current_buffer = vim.api.nvim_get_current_buf()
	local current_file = vim.api.nvim_buf_get_name(current_buffer)
	local parent = vim.fn.fnamemodify(current_file, ":h:t")
	if parent == "." then
		return ""
	end
	return parent .. "/"
end

M.get_current_filename = function()
	local bufname = vim.api.nvim_buf_get_name(0)
	local filename = bufname ~= "" and vim.fn.fnamemodify(bufname, ":t") or ""
	return M.get_parent_folder() .. filename
end

M.toggle_quickfix = function()
	local windows = vim.fn.getwininfo()

	for _, win in pairs(windows) do
		if win["quickfix"] == 1 then
			vim.cmd.cclose()
			return
		end
	end

	vim.cmd.copen()
end

M.jumplist_qf = function()
	local jumplist, _ = unpack(vim.fn.getjumplist())
	local qf_list = {}
	for _, v in pairs(jumplist) do
		if vim.fn.bufloaded(v.bufnr) == 1 then
			table.insert(qf_list, {
				bufnr = v.bufnr,
				lnum = v.lnum,
				col = v.col,
				text = vim.api.nvim_buf_get_lines(v.bufnr, v.lnum - 1, v.lnum, false)[1],
			})
		end
	end
	vim.fn.setqflist(qf_list, " ")
	vim.cmd("copen")
end

return M
