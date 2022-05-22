local M = {}

M.close_buffer = function(force)
   if vim.bo.buftype == "terminal" then
      vim.api.nvim_win_hide(0)
      return
   end

   local fileExists = vim.fn.filereadable(vim.fn.expand "%p")
   local modified = vim.api.nvim_buf_get_option(vim.fn.bufnr(), "modified")

   -- if file doesnt exist & its modified
   if fileExists == 0 and modified then
      print "no file name? add it now!"
      return
   end

   force = force or not vim.bo.buflisted or vim.bo.buftype == "nofile"

   -- if not force, change to prev buf and then close current
   local close_cmd = force and ":bd!" or ":bp | bd" .. vim.fn.bufnr()
   vim.cmd(close_cmd)
end

M.load_config = function()
   local conf = require "core.default_config"
   return conf
end

-- reduces a given keymap to a table of modes each containing a list of key maps
M.reduce_key_map = function(key_map, ignore_modes)
   local prune_keys = {}
   for _, modes in pairs(key_map) do
      for mode, mappings in pairs(modes) do
         if not vim.tbl_contains(ignore_modes, mode) then
            prune_keys[mode] = prune_keys[mode] and prune_keys[mode] or {}
            prune_keys[mode] = vim.list_extend(prune_keys[mode], vim.tbl_keys(mappings))
         end
      end
   end
   return prune_keys
end

-- remove disabled mappings from a given key map
M.remove_disabled_mappings = function(key_map)
   local clean_map = {}
   if type(key_map) == "table" then
      for k, v in pairs(key_map) do
         if v ~= nil and v ~= "" then clean_map[k] = v end
      end
   else
      return key_map
   end
   return clean_map
end

-- prune keys from a key map table by matching against another key map table
M.prune_key_map = function(key_map, prune_map, ignore_modes)
   if not prune_map then return key_map end
   if not key_map then return prune_map end
   local prune_keys = type(prune_map) == "table" and M.reduce_key_map(prune_map, ignore_modes)
       or { n = {}, v = {}, i = {}, t = {} }

   -- for ext, modes in pairs(key_map) do
   --    for mode, mappings in pairs(modes) do
   --       if not vim.tbl_contains(ignore_modes, mode) then
   --          if prune_keys[mode] then
   --             -- filter mappings table so that only keys that are not in user_mappings are left
   --             local filtered_mappings = {}
   --             for k, v in pairs(mappings) do
   --                if not vim.tbl_contains(prune_keys[mode], k) then
   --                   filtered_mappings[k] = M.remove_disabled_mappings(v)
   --                end
   --             end
   --             key_map[ext][mode] = filtered_mappings
   --          end
   --       end
   --    end
   -- end

   return key_map
end

M.map = function(mode, keys, command, opt)
   local options = { silent = true }

   if opt then
      options = vim.tbl_extend("force", options, opt)
   end

   if type(keys) == "table" then
      for _, keymap in ipairs(keys) do
         M.map(mode, keymap, command, opt)
      end
      return
   end

   vim.keymap.set(mode, keys, command, opt)
end

-- For those who disabled whichkey
M.no_WhichKey_map = function()
   local mappings = M.load_config().mappings
   local ignore_modes = { "mode_opts" }

   for _, value in pairs(mappings) do
      for mode, keymap in pairs(value) do
         if not vim.tbl_contains(ignore_modes, mode) then
            for keybind, cmd in pairs(keymap) do
               -- disabled keys will not have cmd set
               if cmd ~= "" then
                  M.map(mode, keybind, cmd[1])
               end
            end
         end
      end
   end

   require("plugins.configs.others").misc_mappings()
end

-- load plugin after entering vim ui
M.packer_lazy_load = function(plugin, timer)
   if plugin then
      timer = timer or 0
      vim.defer_fn(function()
         require("packer").loader(plugin)
      end, timer)
   end
end

-- remove plugins defined in chadrc
M.remove_default_plugins = function(plugins)
    local removals = {
        "2html_plugin",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
    }

   if not vim.tbl_isempty(removals) then
      for _, plugin in pairs(removals) do
         plugins[plugin] = nil
      end
   end

   return plugins
end

-- merge default/user plugin tables
M.plugin_list = function(default_plugins)
   default_plugins = vim.tbl_deep_extend("force", default_plugins, {})

   local final_table = {}

   for key, _ in pairs(default_plugins) do
      default_plugins[key][1] = key

      final_table[#final_table + 1] = default_plugins[key]
   end

   return final_table
end

M.load_override = function(default_table, plugin_name)
   local user_table = M.load_config().plugins.override[plugin_name]

   if type(user_table) == "table" then
      default_table = vim.tbl_deep_extend("force", default_table, user_table)
   else
      default_table = default_table
   end

   return default_table
end

return M
