local present, hop = pcall(require, "hop")

if not present then
    return false
end

hop.setup()

local hint = require("hop.hint")
local map = require("core.utils").map

map('n', 'f', function()
    hop.hint_char1({ direction = hint.HintDirection.AFTER_CURSOR, current_line_only = true })
end, { silent = false })

map('n', 'F', function()
    hop.hint_char1({ direction = hint.HintDirection.BEFORE_CURSOR, current_line_only = true })
end, { silent = false })

map('n', 't', function()
    hop.hint_char1({ direction = hint.HintDirection.BEFORE_CURSOR, current_line_only = true, hint_offset = -1 })
end, { silent = false })

map('n', 'T', function()
    hop.hint_char1({ direction = hint.HintDirection.AFTER_CURSOR, current_line_only = true, hint_offset = 1 })
end, { silent = false })
