local function label(n)
	local buflist = vim.fn.tabpagebuflist(n)
	local winnr = vim.fn.tabpagewinnr(n)
	local bufname = vim.fn.bufname(buflist[winnr])

	if bufname == "" then
		return "[No Name]"
	elseif bufname:sub(1, 6) == "oil://" then
		return "oil"
	else
		local bufname = vim.fn.fnamemodify(bufname, ":t")
		return ("%d:%s"):format(n, bufname)
	end
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

	-- -- right-align the label to close the current tab page
	-- if tabcount > 1 then
	-- 	s = s .. "%=%#TabLine#%999Xclose"
	-- end

	return s
end

vim.opt.tabline = "%!v:lua.Tabline()"
