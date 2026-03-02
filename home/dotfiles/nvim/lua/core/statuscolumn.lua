_G.StatuscolSign = function()
	local marks = vim.api.nvim_buf_get_extmarks(
		0,
		-1,
		{ vim.v.lnum - 1, 0 },
		{ vim.v.lnum - 1, -1 },
		{ details = true }
	)
	for _, mark in ipairs(marks) do
		local details = mark[4]
		if details and details.sign_text then
			local hl = details.sign_hl_group or "SignColumn"
			return "%#" .. hl .. "#" .. details.sign_text .. "%*"
		end
	end
	return "   "
end

vim.opt.statuscolumn = "%{%v:lua.StatuscolSign()%}%=%4{v:relnum == 0 ? v:lnum : v:relnum}  "
