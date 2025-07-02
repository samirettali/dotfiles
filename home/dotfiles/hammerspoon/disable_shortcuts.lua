-- hack to disable cmd+m
local function noop() end

hs.hotkey.bind({ "cmd" }, "m", noop)
hs.hotkey.bind({ "cmd" }, "h", noop)
hs.hotkey.bind({ "cmd", "alt" }, "h", noop)
