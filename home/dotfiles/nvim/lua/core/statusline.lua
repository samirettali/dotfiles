local utils = require("core.utils")

local function name()
	if utils.is_plugin_filetype() then
		return ""
	end

	return utils.get_current_filename()
end

-- function Statusline()
-- 	return ("%%#Statusline# %s %s %s %s %s"):format(
-- 		-- bracketize(branch()),
-- 		utils.bracketed_group(name()),
-- 		utils.bracketed_group(utils.lsp_servers()),
-- 		utils.bracketed_group(utils.gitsigns()),
-- 		utils.bracketed_group(utils.get_diagnostics(0))
-- 	)
-- end

function Statusline()
	return " "
end

vim.opt.statusline = [[%!luaeval("Statusline()")]]
