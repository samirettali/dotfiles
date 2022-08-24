#!/usr/bin/env lua
local present, mcc = pcall(require, "mcc")

if not present then
    return false
end

local config = {
    c = {'-','->','-','-----','-------'},
    go = { ';',':=',';'},
    rust = {';','::',';'},
    go = {
        { ';',':=',';'},
        { '/',':=',';'},
    }
}

mcc.setup(config)
