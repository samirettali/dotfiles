local utils = require("core.utils")

local function lsp()
	local count = {}
	local levels = {
		errors = "Error",
		warnings = "Warn",
		info = "Info",
		hints = "Hint",
	}

	for k, level in pairs(levels) do
		count[k] = vim.tbl_count(vim.diagnostic.get(nil, { severity = level }))
	end

	local errors = ""
	local warnings = ""
	local hints = ""
	local info = ""

	if count["errors"] ~= 0 then
		errors = "%#DiagnosticSignError#E " .. count["errors"] .. " "
	end
	if count["warnings"] ~= 0 then
		warnings = "%#DiagnosticSignWarn#W " .. count["warnings"] .. " "
	end
	if count["hints"] ~= 0 then
		hints = "%#DiagnosticSignHint#H " .. count["hints"] .. " "
	end
	if count["info"] ~= 0 then
		info = "%#DiagnosticSignInfoI #" .. count["info"] .. " "
	end

	local result = errors .. warnings .. hints .. info

	if result ~= "" then
		return " " .. result .. "%#Statusline#"
	end

	return ""
end

local function name()
	if utils.is_plugin_filetype() then
		return ""
	end
	return " %f "
end

local function get_branch_name()
	local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
	if branch ~= "" then
		return branch
	else
		return ""
	end
end

function Statusline()
	local branch = get_branch_name()

	if branch and #branch > 0 then
		branch = "%#Statusline#  " .. branch .. " %#Statusline#"
	end

	return "%#Statusline#" .. branch .. " " .. "%{get(b:,'gitsigns_status','')}" .. "%=" .. lsp()
end

-- vim.opt.statusline = [[%!luaeval("Statusline()")]]

vim.cmd([[
    " hi! link StatusLine Normal
    " hi! link StatusLineNC Normal
    set statusline=
]])
