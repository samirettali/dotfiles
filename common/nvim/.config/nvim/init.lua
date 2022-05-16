local present, impatient = pcall(require, "impatient")

if present then
    impatient.enable_profile()
end

local core_modules = {
   "core.options",
   "core.autocmds",
   "core.mappings",
}

for _, module in ipairs(core_modules) do
   local ok, err = pcall(require, module)
   if not ok then
      error("Error loading " .. module .. "\n\n" .. err)
   end
end

-- check if custom init.lua file exists
if vim.fn.filereadable(vim.fn.stdpath "config" .. "/lua/custom/init.lua") == 1 then
   -- try to call custom init, if not successful, show error
   local ok, err = pcall(require, "custom")

   if not ok then
      vim.notify("Error loading custom/init.lua\n\n" .. err)
   end

   return
end

-- Load plugins

-- Load plugins settings
-- require 'samir.autopairs'
-- require 'samir.camelcasemotion'
-- require 'samir.cmp'
-- require 'samir.colorizer'
-- require 'samir.comment'
-- require 'samir.feline'
-- require 'samir.gitblame'
-- require 'samir.gitsigns'
-- require 'samir.go'
-- require 'samir.highlightedundo'
-- require 'samir.tabby'
-- require 'samir.illuminate'
-- require 'samir.indentline'
-- require 'samir.matchtag'
-- require 'samir.oscyank'
-- require 'samir.ripgrep'
-- require 'samir.scalpel'
-- require 'samir.scrollview'
-- require 'samir.sneak'
-- require 'samir.splitline'
-- require 'samir.telescope'
-- require 'samir.neotree'
-- require 'samir.treesitter'
-- require 'samir.treesitter-textobjects'
-- require 'samir.trouble'
-- require 'samir.vimgo'
-- require 'samir.vista'
-- require 'samir.vsnip'

-- Vimscript stuff
-- require 'samir.vimscript'

-- Disabled
-- require 'samir.lspkind'
-- require 'samir.tree'
