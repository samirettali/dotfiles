local utils = require("core.utils")

local diagnostic_highlights = {
	[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
	[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
	[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
	[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
}

function diagnostics()
	local counts = vim.diagnostic.count()
	local user_signs = vim.tbl_get(vim.diagnostic.config() --[[@as vim.diagnostic.Opts]], "signs", "text") or {}
	local signs = vim.tbl_extend("keep", user_signs, { "E", "W", "I", "H" })
	local result_str = vim.iter(pairs(counts))
		:map(function(severity, count)
			local highlight = diagnostic_highlights[severity]
			return utils.with_hl(highlight, signs[severity], ":", count)
		end)
		:join(" ")

	if result_str == "" then
		return ""
	end

	return "[" .. result_str .. "]"
end

local function name()
	if utils.is_plugin_filetype() then
		return ""
	end
	return " %f "
end

local function lsp_server()
	local clients = vim.lsp.get_clients({
		bufnr = vim.api.nvim_get_current_buf(),
	})

	if rawequal(next(clients), nil) then
		return ""
	end

	local result_str = vim.iter(ipairs(clients))
		:map(function(_, client)
			return client.name
		end)
		:join(" ")

	return ("[%s]"):format(result_str)

	-- local format = "LSP:"
	-- local format = ""
	--
	-- for _, client in ipairs(clients) do
	-- 	format = string.format("%s [%s]", format, client.name)
	-- end
	--
	-- return format
end

local function gitsigns()
	local status = vim.b[0].gitsigns_status_dict

	if not status then
		return ""
	end

	local parts = {}

	if status.added and status.added > 0 then
		local part = utils.with_hl("GitSignsAdd", "+", status.added)
		table.insert(parts, part)
	end

	if status.changed and status.changed > 0 then
		local part = utils.with_hl("GitSignsChange", "~", status.changed)
		table.insert(parts, part)
	end

	if status.removed and status.removed > 0 then
		local part = utils.with_hl("GitSignsDelete", "-", status.removed)
		table.insert(parts, part)
	end

	if #parts == 0 then
		return ""
	end

	return "[" .. table.concat(parts, " ") .. "]"
end

function Statusline()
	return ("%%#Statusline# %s %s %s"):format(lsp_server(), diagnostics(), gitsigns())
end

vim.opt.statusline = [[%!luaeval("Statusline()")]]
