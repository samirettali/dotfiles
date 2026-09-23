local M = {}

local api = vim.api

local function mode_suffix(mode)
	if vim.startswith(mode, "i") or mode == "t" then
		return "Insert"
	elseif vim.startswith(mode, "n") then
		return "Normal"
	elseif vim.startswith(mode, "R") then
		return "Replace"
	elseif vim.startswith(mode:lower(), "v") then
		return "Visual"
	elseif mode == "c" then
		return "Command"
	else
		return "Other"
	end
end

-- Moonfly defines the MiniStatuslineMode* groups; the default colorscheme,
-- used in light mode, does not.
M.get_mode_hl = function()
	local group = "MiniStatuslineMode" .. mode_suffix(api.nvim_get_mode().mode)
	if next(api.nvim_get_hl(0, { name = group })) == nil then
		return "TabLineSel"
	end
	return group
end

return M
