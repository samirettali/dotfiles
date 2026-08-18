local canvas = require("canvas")
local frecency = require("frecency")

local M = {}

-- the emojione dataset that ships inside Emojis.spoon, which nix already pins.
-- Reading it beats vendoring a second copy that would drift from it.
local SOURCE = hs.configdir .. "/Spoons/Emojis.spoon/emojis/emojis.json"

local uses = frecency.new("emoji.uses")
local cached = nil

local function character(entry)
	local points = entry.code_points and entry.code_points.fully_qualified

	if not points then
		return nil
	end

	local out = {}

	for hex in points:gmatch("[^%-]+") do
		out[#out + 1] = utf8.char(tonumber(hex, 16))
	end

	return table.concat(out)
end

local function load()
	if cached then
		return cached
	end

	local file = io.open(SOURCE, "r")

	if not file then
		return nil
	end

	local decoded = hs.json.decode(file:read("a"))

	file:close()

	if not decoded then
		return nil
	end

	local list = {}

	for _, entry in pairs(decoded) do
		-- display filters the duplicate encodings out, and an entry with a
		-- diversity is one skin tone of another entry already in the list
		if entry.display == 1 and not entry.diversity then
			local glyph = character(entry)

			if glyph then
				table.insert(list, {
					glyph = glyph,
					name = entry.name,
					shortname = (entry.shortname or ""):gsub(":", ""),
					keywords = table.concat(entry.keywords or {}, " "),
					order = entry.order or 0,
				})
			end
		end
	end

	table.sort(list, function(a, b)
		return a.order < b.order
	end)

	cached = list

	return cached
end

function M.open()
	local list = load()

	if not list or #list == 0 then
		hs.alert.show("emoji: could not read the emoji list")
		return true
	end

	local score = uses.scores()
	local choices = {}

	for _, entry in ipairs(list) do
		table.insert(choices, {
			text = entry.glyph .. "  " .. entry.name,
			subText = entry.shortname .. (entry.keywords ~= "" and (" · " .. entry.keywords) or ""),
			glyph = entry.glyph,
			boost = score(entry.glyph),
		})
	end

	canvas.picker({
		prompt = "emoji",
		choices = choices,
		onSelect = function(choice)
			uses.remember(choice.glyph)

			-- typed rather than pasted, so the pasteboard is left alone
			hs.timer.doAfter(0.2, function()
				hs.eventtap.keyStrokes(choice.glyph)
			end)
		end,
		-- shift+return copies it instead, for somewhere that will not take the
		-- synthesised keystrokes
		onAlternate = function(choice)
			uses.remember(choice.glyph)
			hs.pasteboard.setContents(choice.glyph)
			hs.alert.show("emoji: copied " .. choice.glyph)
		end,
	})

	return true
end

return M
