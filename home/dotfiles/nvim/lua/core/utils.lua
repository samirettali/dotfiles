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

--- Returns true if a buffer is a plugin filetype.
--- @param bufnr integer|nil The buffer number to check. Defaults to the current
M.is_plugin_filetype = function(bufnr)
	return vim.tbl_contains(M.plugin_filetypes, vim.b[bufnr or 0].filetype)
end

M.get_parent_folder = function(bufnr)
	local filename = vim.api.nvim_buf_get_name(bufnr or 0)

	local parent = vim.fn.fnamemodify(filename, ":h:t")

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

M.with_hl = function(highlight, ...)
	local args = { ... }
	if #args == 0 then
		return ""
	end

	local result = {
		"%#",
		highlight,
		"#",
	}
	for _, arg in ipairs(args) do
		table.insert(result, arg)
	end

	table.insert(result, "%*")

	return table.concat(result, "")
end

local diagnostic_highlights = {
	[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
	[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
	[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
	[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
}

M.get_diagnostics = function(bufnr)
	local counts = vim.diagnostic.count(bufnr or 0)
	local user_signs = vim.tbl_get(vim.diagnostic.config() --[[@as vim.diagnostic.Opts]], "signs", "text") or {}
	local signs = vim.tbl_extend("keep", user_signs, { "E", "W", "I", "H" })

	local result_str = vim.iter(pairs(counts))
		:map(function(severity, count)
			local highlight = diagnostic_highlights[severity]
			return M.with_hl(highlight, signs[severity], ":", count)
		end)
		:join(" ")

	return result_str
end

-- M.hl = function(highlight, ...)
-- 	return {
-- 		hl = highlight,
-- 		text = table.concat({ ... }, ""),
-- 	}
-- end

-- M.diagnostics = function(bufnr)
-- 	local counts = vim.diagnostic.count(bufnr or 0)
-- 	local user_signs = vim.tbl_get(vim.diagnostic.config() --[[@as vim.diagnostic.Opts]], "signs", "text") or {}
-- 	local signs = vim.tbl_extend("keep", user_signs, { "E", "W", "I", "H" })
--
-- 	return vim.iter(pairs(counts)):map(function(severity, count)
-- 		local highlight = diagnostic_highlights[severity]
-- 		return M.hl(highlight, signs[severity], ":", count)
-- 	end)
-- end

-- M.gitsigns = function(bufnr)
-- 	local status = vim.b[bufnr or 0].gitsigns_status_dict
--
-- 	local parts = {}
--
-- 	if not status then
-- 		return parts
-- 	end
--
-- 	if status.added and status.added > 0 then
-- 		local part = M.hl("GitSignsAdd", "+", status.added)
-- 		table.insert(parts, part)
-- 	end
--
-- 	if status.changed and status.changed > 0 then
-- 		local part = M.hl("GitSignsChange", "~", status.changed)
-- 		table.insert(parts, part)
-- 	end
--
-- 	if status.removed and status.removed > 0 then
-- 		local part = M.hl("GitSignsDelete", "-", status.removed)
-- 		table.insert(parts, part)
-- 	end
--
-- 	return parts
-- end

M.get_gitsigns = function(bufnr)
	local status = vim.b[bufnr or 0].gitsigns_status_dict

	if not status then
		return ""
	end

	local parts = {}

	if status.added and status.added > 0 then
		local part = M.with_hl("GitSignsAdd", "+", status.added)
		table.insert(parts, part)
	end

	if status.changed and status.changed > 0 then
		local part = M.with_hl("GitSignsChange", "~", status.changed)
		table.insert(parts, part)
	end

	if status.removed and status.removed > 0 then
		local part = M.with_hl("GitSignsDelete", "-", status.removed)
		table.insert(parts, part)
	end

	return table.concat(parts, " ")
end

M.lsp_servers = function(bufnr)
	local clients = vim.lsp.get_clients({
		bufnr = bufnr or 0,
	})

	if rawequal(next(clients), nil) then
		return ""
	end

	return vim.iter(ipairs(clients))
		:map(function(_, client)
			return client.name
		end)
		:join(" ")
end

local function group(separator, open, close, ...)
	local args = { ... }

	local ok
	for _, arg in ipairs(args) do
		if type(arg) == "string" and arg ~= "" then
			ok = true
			break
		end
	end

	-- TODO: this sucks
	if not ok then
		return ""
	end

	if #args == 1 then
		return ("[%s]"):format(args[1])
	end

	local result = ("%s%s%s"):format(open, table.concat(args, separator), close)

	return result
end

M.bracketed_group = function(...)
	return group(" ", "[", "]", ...)
end

M.branch_name = function()
	return vim.b[0].gitsigns_head or ""
end

M.concat = function(items, sep)
	return vim.iter(ipairs(items))
		:map(function(_, arg)
			if type(arg) == "string" then
				return arg
			elseif type(arg) == "number" then
				return tostring(arg)
			elseif type(arg) == "boolean" then
				return arg and "true" or "false"
			elseif type(arg) == "table" then
				error("called utils.concat with unsupported type:" .. type(arg))
				-- elseif type(arg) == "table" then -- TODO: use hl and custom object
				-- 	return "%#" .. arg.hl .. "#" .. arg.text .. "%*"
			end
		end)
		:filter(function(s)
			return s ~= nil and s ~= ""
		end)
		:join(sep or "")
end

--- Get mark for a line
--- @param buf number Buffer number
--- @param lnum number Line number
M.get_mark_sign = function(buf, lnum)
	local marks = vim.fn.getmarklist(buf)
	vim.list_extend(marks, vim.fn.getmarklist())

	for _, mark in ipairs(marks) do
		if mark.pos[1] == buf and mark.pos[2] == lnum and mark.mark:match("[a-zA-Z]") then
			return {
				text = mark.mark:sub(2),
				hl = "DiagnosticHint", -- TODO
			}
		end
	end

	return nil
end

-- Toggle line highlight
M.toggle_line_highlight = function()
	local line_num = vim.fn.line(".")
	local highlight_group = "LineHighlight"

	local matches = vim.fn.getmatches()
	local match_id = nil

	for _, match in ipairs(matches) do
		if match.group == highlight_group and match.pattern == "\\%" .. line_num .. "l" then
			match_id = match.id
			break
		end
	end

	if match_id then
		vim.fn.matchdelete(match_id)
	else
		vim.cmd("highlight LineHighlight ctermbg=gray guibg=gray")
		vim.fn.matchadd("LineHighlight", "\\%" .. line_num .. "l")
	end
end

M.clear_line_highlight = function()
	vim.cmd("<CMD>call clearmatches()<CR>")
end

M.delete_hidden_buffers = function(options)
	local force = options and options.force or false
	local buffers = vim.api.nvim_list_bufs()

	-- Get all windows across all tabs
	local function is_buffer_visible(buffer)
		for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
			for _, window in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
				if vim.api.nvim_win_get_buf(window) == buffer then
					return true
				end
			end
		end
		return false
	end

	for _, buffer in ipairs(buffers) do
		if vim.fn.buflisted(buffer) == 1 and not is_buffer_visible(buffer) then
			if force then
				vim.api.nvim_command("bwipeout! " .. buffer)
			else
				vim.api.nvim_command("bwipeout " .. buffer)
			end
		end
	end
end

M.duplicate_and_comment_lines = function()
	local start_line, end_line = vim.api.nvim_buf_get_mark(0, "[")[1], vim.api.nvim_buf_get_mark(0, "]")[1]

	-- NOTE: `nvim_buf_get_mark()` is 1-indexed, but `nvim_buf_get_lines()` is 0-indexed. Adjust accordingly.
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	-- Store cursor position because it might move when commenting out the lines.
	local cursor = vim.api.nvim_win_get_cursor(0)

	-- Comment out the selection using the builtin gc operator.
	vim.cmd.normal({ "gcc", range = { start_line, end_line } })
	-- to make it dot repeatable if vim-repeat does not work
	-- require("mini.comment").toggle_lines(start_line, end_line)

	-- Append a duplicate of the selected lines to the end of selection.
	vim.api.nvim_buf_set_lines(0, end_line, end_line, false, lines)

	-- Move cursor to the start of the duplicate lines.
	vim.api.nvim_win_set_cursor(0, { end_line + 1, cursor[2] })
end

return M
