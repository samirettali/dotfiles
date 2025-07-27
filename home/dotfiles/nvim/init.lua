vim.loader.enable()

P = function(x)
	print(vim.inspect(x))
	return x
end

local function load_modules()
	local modules = {
		"core.options",
		"core.abbreviations",
		"core.autocmds",
		"core.lsp",
		"core.diagnostic",
		-- "core.statusline",
		-- "core.winbar",
		"core.mappings",
		-- "core.largefile",
	}

	for _, module in ipairs(modules) do
		package.loaded[module] = nil
		local ok, err = pcall(require, module)
		if not ok then
			error("Error loading " .. module .. "\n\n" .. err)
		end
	end
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

vim.opt.rtp:prepend(lazypath)

load_modules()

local opts = {
	defaults = { lazy = true },
	dev = { path = "~/dev/nvim" },
}

require("lazy").setup({ import = "plugins" }, opts)
