#!/usr/bin/env lua
local present, lspkind = pcall(require, "lspkind")

if not present then
    return false
end

local config = {
    mode = 'symbol_text',
    preset = 'default',
}

lspkind.init(config)
