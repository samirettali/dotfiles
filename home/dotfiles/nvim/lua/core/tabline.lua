local utils = require("core.utils")

local function label(n)
	-- TODO: move to utils
	local buflist = vim.fn.tabpagebuflist(n)
	local winnr = vim.fn.tabpagewinnr(n)
	local bufname = vim.fn.bufname(buflist[winnr])
	local buftype = vim.fn.getbufvar(buflist[winnr], "&filetype")
	local title

	if bufname == "" then
		title = "[No Name]"
	elseif bufname:sub(1, 6) == "oil://" then
		title = "oil"
	elseif buftype == "codecompanion" then
		title = "CodeCompanion"
	else
		title = vim.fn.fnamemodify(bufname, ":t")
	end

	return (" %d:%s "):format(n, title)
end

function Tabline()
	local tabcount = vim.fn.tabpagenr("$")
	local current_tab = vim.fn.tabpagenr()

	local left_parts = {}

	for i = 1, tabcount do
		local hl

		if i == current_tab then
			hl = "TabLineSel"
		else
			hl = "TabLine"
		end

		local tab_label = ("%%%dT%s"):format(i, utils.with_hl(hl, label(i)))

		table.insert(left_parts, tab_label)
	end

	local parts = {
		utils.with_hl("MoonflyEmerald", "  "),
		table.concat(left_parts, ""),
		"%#TabLineFill#", -- "%T"
	}

	table.insert(parts, "%=") -- align to the right

	return utils.concat(parts, "")
end

vim.opt.tabline = "%!v:lua.Tabline()"
