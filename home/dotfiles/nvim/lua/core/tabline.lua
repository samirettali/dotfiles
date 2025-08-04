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
	local s = ""
	local tabcount = vim.fn.tabpagenr("$")
	local current_tab = vim.fn.tabpagenr()

	local parts = { " " }

	for i = 1, tabcount do
		local bufnr = vim.fn.tabpagebuflist(i)[vim.fn.tabpagewinnr(i)]

		if i == current_tab then
			table.insert(parts, "%#TabLineSel#")
		else
			table.insert(parts, "%#TabLine#")
		end

		table.insert(parts, ("%%%dT"):format(i)) -- set the tab page number (for mouse clicks)
		table.insert(parts, label(i))
	end

	table.insert(parts, "%#TabLineFill#") -- "%T"

	table.insert(parts, "%=") -- align to the right

	local right = utils.concat({
		utils.bracketed_group(utils.get_gitsigns()),
		utils.bracketed_group(utils.get_diagnostics()),
	}, " ")

	table.insert(parts, right)

	return utils.concat(parts, "")
end

vim.opt.tabline = "%!v:lua.Tabline()"
