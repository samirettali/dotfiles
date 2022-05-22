#!/usr/bin/env lua
-- IMPORTANT NOTE : This is default config, so dont change anything here.
-- chadrc overrides this file

local M = {}

M.plugins = {
   override = {},
   remove = {},

   options = {
      packer = {
         init_file = "plugins.packerInit",
         snapshot = nil,
      },
      lspconfig = {
         setup_lspconf = "", -- path of lspconfig file
      },
   },

}

return M
