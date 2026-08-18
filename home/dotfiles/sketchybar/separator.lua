local colors = require("colors")

local separator = {}

-- Right-side items render in creation order, rightmost first, so a separator
-- added between two `require` calls lands between those two groups.
-- `nudge` shifts the rule right by that many points. Equal padding still looks
-- unequal because each neighbour leaves a different amount of empty box around
-- its glyph, so the gaps are balanced by ink, measured from a screenshot.
function separator.add(name, nudge)
	return sbar.add("item", "separator." .. name, {
		position = "right",
		icon = { drawing = false },
		-- Sketchybar sizes a label from the glyph's tight bounding box, and the
		-- pipe's is two pixels wide, so without an explicit width it is clipped
		-- away entirely.
		label = {
			string = "|",
			color = colors.grey39,
			width = 10,
			align = "left",
			padding_left = nudge or 0,
			padding_right = 0,
		},
		padding_left = 2,
		padding_right = 2,
	})
end

return separator
