local M = {}

-- if theme given, load given theme if given, otherwise nvchad_theme
M.init = function(theme)
   if not theme then
      theme = "tokyonight"
   end

   -- set the global theme, used at various places like theme switcher, highlights
   vim.g.nvchad_theme = theme

   local present, base16 = pcall(require, "base16")

   if present then
      -- first load the base16 theme
      base16(base16.themes(theme), true)

      -- unload to force reload
      package.loaded["samir.colors.highlights" or false] = nil
      -- then load the highlights
      require "samir.colors.highlights"
   else
      return false
   end
end

-- returns a table of colors for givem or current theme
M.get = function(theme)
   if not theme then
      theme = "tokyonight"
   end

   return require("hl_themes." .. theme)
end

return M
