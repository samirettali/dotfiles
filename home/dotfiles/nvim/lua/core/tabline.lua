local function label(n)
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

	return ("%d:%s"):format(n, title)
end

function Tabline()
	local s = ""
	local tabcount = vim.fn.tabpagenr("$")
	local current_tab = vim.fn.tabpagenr()

	for i = 1, tabcount do
		if i == current_tab then
			s = s .. "%#TabLineSel#"
		else
			s = s .. "%#TabLine#"
		end

		-- set the tab page number (for mouse clicks)
		s = s .. "%" .. i .. "T"

		s = s .. " " .. label(i) .. " "
	end

	s = s .. "%#TabLineFill#%T"

	return s
end

vim.opt.tabline = "%!v:lua.Tabline()"
