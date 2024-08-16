local M = {}

M.is_empty = function(s)
	return s == nil or s == ""
end

M.get_buf_option = function(opt)
	local status_ok, buf_option = pcall(vim.api.nvim_buf_get_option, 0, opt)
	if not status_ok then
		return nil
	else
		return buf_option
	end
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

return M
