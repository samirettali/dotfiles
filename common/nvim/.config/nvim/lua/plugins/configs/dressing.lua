#!/usr/bin/env lua
local present, dressing = pcall(require, "dressing")

if not present then
    return false
end

dressing.setup()
