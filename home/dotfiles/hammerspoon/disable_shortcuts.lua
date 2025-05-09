-- hack to disable cmd+m
local function noop() end

hs.hotkey.bind({ "cmd" }, "m", noop)
