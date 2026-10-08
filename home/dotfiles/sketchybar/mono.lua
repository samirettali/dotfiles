local mono = {}

-- Sketchybar sizes a label from its glyphs' ink, so even in a monospace font a
-- trailing `1` makes a narrower label than a `0`, a ticking number shifts every
-- item beside it, and padding spaces count for nothing. A width from the
-- advance keeps the box still: JetBrains Mono advances 0.6 em, 8.4 points at
-- the 14-point size set in `bar.lua`.
local ADVANCE = 14 * 0.6
-- An explicit width replaces the paddings too; these are the 4 + 4 of `bar.lua`.
local PADDING = 8

function mono.width(text, padding)
	return math.ceil((utf8.len(text) or #text) * ADVANCE) + (padding or PADDING)
end

return mono
