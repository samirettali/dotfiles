#!/usr/bin/env lua
local present, cloak = pcall(require, "cloak")
if not present then
    return false
end

local map = require("core.utils").map

local config = {
    enabled = true,
    cloak_character = '*',
    highlight_group = 'Comment',
    patterns = {
        {
            file_pattern = { ".env*", "*.env" },
            cloak_pattern = '=.+'
        },
    },
}

cloak.setup(config)

map("n", "<Leader>ct", cloak.toggle)
