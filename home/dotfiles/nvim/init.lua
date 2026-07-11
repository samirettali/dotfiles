vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- functions
function P(x)
	print(vim.inspect(x))
	return x
end

function N(x, level, opts)
	vim.notify(vim.inspect(x), level, opts)
	return x
end

require("plugins.start")

vim.cmd("packadd nvim.undotree") -- built in

require("options")

require("ui.tabline")
require("autocmds")
require("plugins.nightfly")
require("plugins.auto-dark-mode")

require("lsp")

-- plugins setup
require("plugins")

require("commands")

require("keymaps")

----------------- yooooooooooo
-- vim.opt.wildmode = "noselect"
-- vim.api.nvim_create_autocmd("CmdlineChanged", {
-- 	pattern = ":",
-- 	callback = function()
-- 		vim.fn.wildtrigger()
-- 	end,
-- })

-- function _G.my_find(text, _)
-- 	local files = vim.fn.glob("**/*", true, true)
-- 	-- return { "%#DiagnosticError#" .. text .. "%*" .. "\t" .. "%#DiagnosticHint#" .. "in " .. files }
-- 	local result = vim.fn.matchfuzzy(files, text)
-- 	P(result)
-- 	return result
-- end
--
-- vim.opt.findfunc = "v:lua.my_find"

-------------------------------------
