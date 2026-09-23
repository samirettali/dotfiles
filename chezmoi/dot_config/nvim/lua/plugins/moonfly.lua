vim.pack.add({ "https://github.com/bluz71/vim-moonfly-colors" })

vim.g.moonflyTransparent = true
local moonfly = require("moonfly")

local palette = moonfly.palette

vim.g.moonflyWinSeparator = 2
vim.g.moonflyVirtualTextColor = true
vim.g.moonflyNormalFloat = true
vim.g.moonflyNormalPmenu = true
-- vim.g.moonflyUnderlineMatchParen = true -- TODO: needed?
vim.g.moonflyItalics = false
-- vim.g.moonflyUndercurls = true

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("MoonflyColors", { clear = true }),
	pattern = "moonfly",
	callback = function()
		vim.api.nvim_set_hl(0, "WinBar", {
			fg = palette.grey39,
		})

		vim.api.nvim_set_hl(0, "WinBarNC", {
			fg = palette.grey39,
		})

		vim.api.nvim_set_hl(0, "TablineSel", {
			fg = palette.white,
		})

		vim.api.nvim_set_hl(0, "Tabline", {
			fg = palette.grey39,
		})

		vim.api.nvim_set_hl(0, "TreesitterContext", {
			bg = "NONE",
		})

		vim.api.nvim_set_hl(0, "StatusLine", {
			bg = "NONE",
		})

		vim.api.nvim_set_hl(0, "NormalFloatPreview", {
			bg = palette.grey11,
		})
	end,
})

-- Neovim sets 'background' from the terminal's reply to OSC 11 at startup, and
-- again when Ghostty reports a theme change (mode 2031). It stops following
-- once 'background' is set from anywhere but Lua, and moonfly runs
-- `set background=dark`.
local current

local function apply(background)
	local name = background == "dark" and "moonfly" or "default"
	if current == name then
		return
	end
	current = name

	vim.cmd.colorscheme(name)
	-- Without g:colors_name, a later 'background' change does not reload
	-- moonfly, which would force dark again (:h 'background').
	vim.g.colors_name = nil
end

local startup_background = vim.o.background
apply(startup_background)

-- Scheduled code sets options as Lua, not as this file, so Neovim keeps
-- following; the autocmd is created here to inherit that.
vim.schedule(function()
	vim.o.background = startup_background
	vim.api.nvim_create_autocmd("OptionSet", {
		group = vim.api.nvim_create_augroup("FollowBackground", { clear = true }),
		pattern = "background",
		callback = function()
			local background = vim.o.background
			apply(background)
			vim.o.background = background
		end,
	})
end)
