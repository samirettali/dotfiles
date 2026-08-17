local modalFocus = require("modal_focus")

local M = {}

-- one modal at a time: prompt and picker share the canvas and the keyboard tap
local active = nil

local function resolveStyle(opts)
	local base = hs.alert.defaultStyle or {}

	return {
		fill = opts.fillColor or base.fillColor or { black = 1, alpha = 1 },
		stroke = opts.strokeColor or base.strokeColor or { white = 1, alpha = 1 },
		strokeWidth = opts.strokeWidth or base.strokeWidth or 2,
		color = opts.textColor or base.textColor or { white = 1, alpha = 1 },
		font = opts.textFont or base.textFont or "JetBrainsMono Nerd Font",
		size = opts.textSize or base.textSize or 18,
		radius = opts.borderRadius or base.radius or 27,
	}
end

local function fade(color, alpha)
	local faded = { alpha = alpha }

	for _, channel in ipairs({ "red", "green", "blue", "white" }) do
		faded[channel] = color[channel]
	end

	return faded
end

-- Same geometry as hs.alert, so this matches the RecursiveBinder helper: one
-- stroked-and-filled path over the whole canvas. The stroke is centred on that
-- path, so the outer half is clipped away and a strokeWidth of 2 reads as 1.
-- Insetting it instead would draw a border twice as thick as every alert.
local function chrome(_, _, s)
	return {
		{
			type = "rectangle",
			action = "strokeAndFill",
			fillColor = s.fill,
			strokeColor = s.stroke,
			strokeWidth = s.strokeWidth,
			roundedRectRadii = { xRadius = s.radius, yRadius = s.radius },
		},
	}
end

local function textWidth(text, font, size)
	if text == "" then
		return 0
	end

	local styled = hs.styledtext.new(text, { font = { name = font, size = size } })
	local box = hs.drawing.getTextDrawingSize(styled)

	if box and box.w then
		return box.w
	end

	-- an unmeasurable string would collapse the panel, so fall back to the
	-- advance of the monospace face rather than to zero
	return (utf8.len(text) or #text) * size * 0.6
end

local function geometry(width, height, y)
	local screen = hs.screen.mainScreen():fullFrame()

	return {
		x = screen.x + (screen.w - width) / 2,
		y = y or (screen.y + screen.h * (1 - 1 / 1.55) + 55),
		w = width,
		h = height,
	}
end

local function newCanvas(width, height, y)
	local canvas = hs.canvas.new(geometry(width, height, y))

	canvas:level(hs.canvas.windowLevels.mainMenu)
	canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)

	return canvas
end

local function close()
	if not active then
		return
	end

	if active.tap then
		active.tap:stop()
	end

	if active.canvas then
		active.canvas:delete()
	end

	local focus = active.focus
	active = nil
	modalFocus.restore(focus)
end

-- the tap swallows every keyDown while a modal is up, so an error inside the
-- handler would leave the keyboard unusable until Hammerspoon is reloaded
local function startTap(handler)
	return hs.eventtap
		.new({ hs.eventtap.event.types.keyDown }, function(event)
			local ok, err = pcall(handler, event)

			if not ok then
				close()
				hs.alert.show("canvas: " .. tostring(err))
			end

			return true
		end)
		:start()
end

-- utf8-aware: a continuation byte is 10xxxxxx, so walk back over those first
local function dropLastChar(str)
	local i = #str

	while i > 1 and str:byte(i) >= 0x80 and str:byte(i) < 0xC0 do
		i = i - 1
	end

	return str:sub(1, i - 1)
end

local function editBuffer(buffer, event)
	local keyCode = event:getKeyCode()
	local flags = event:getFlags()
	local char = event:getCharacters()
	local map = hs.keycodes.map

	if keyCode == map["delete"] then
		return dropLastChar(buffer), true
	end

	if flags.ctrl and keyCode == map["u"] then
		return "", true
	end

	if flags.ctrl and keyCode == map["w"] then
		return (buffer:gsub("%s*%S+%s*$", "")), true
	end

	if flags.cmd and keyCode == map["v"] then
		return buffer .. (hs.pasteboard.getContents() or ""), true
	end

	if char and #char > 0 and not (flags.cmd or flags.ctrl or flags.alt) then
		return buffer .. char, true
	end

	return buffer, false
end

function M.prompt(opts)
	opts = opts or {}

	if active then
		return false
	end

	local s = resolveStyle(opts)
	local width = opts.width or 600
	local height = opts.height or 100
	local pad = 16
	local titleSize = opts.promptTextSize or math.max(14, s.size - 4)
	local titleHeight = titleSize + 6
	local lineHeight = s.size * 1.35
	local buffer = opts.initialText or ""

	local canvas = newCanvas(width, height, opts.y)
	local elements = chrome(width, height, s)

	table.insert(elements, {
		type = "text",
		text = opts.prompt or "",
		textColor = opts.promptTextColor or fade(s.color, 0.7),
		textSize = titleSize,
		textFont = s.font,
		textAlignment = "center",
		frame = { x = pad, y = pad, w = width - pad * 2, h = titleHeight },
	})

	-- hs.canvas pins text to the top of its frame, so the input has to be
	-- centred in the space left below the title rather than given a tall box
	local inputTop = pad + titleHeight

	table.insert(elements, {
		type = "text",
		text = buffer .. "|",
		textColor = s.color,
		textSize = s.size,
		textFont = s.font,
		textAlignment = "center",
		textLineBreak = "truncateHead",
		frame = {
			x = pad,
			y = inputTop + (height - inputTop - pad - lineHeight) / 2,
			w = width - pad * 2,
			h = lineHeight,
		},
	})

	-- index of the input element, so it survives changes to what chrome() draws
	local inputIndex = #elements

	canvas:replaceElements(table.unpack(elements))
	local focus = modalFocus.take()
	canvas:show()

	active = { canvas = canvas, focus = focus }

	active.tap = startTap(function(event)
		local keyCode = event:getKeyCode()
		local map = hs.keycodes.map

		if keyCode == map["return"] then
			local submit = opts.onSubmit
			close()

			if submit then
				submit(buffer)
			end

			return
		end

		if keyCode == map["escape"] then
			local cancel = opts.onCancel
			close()

			if cancel then
				cancel()
			end

			return
		end

		local updated, changed = editBuffer(buffer, event)

		if changed then
			buffer = updated
			canvas[inputIndex].text = buffer .. "|"
		end
	end)

	return true
end

-- subsequence match: nil when a character is missing, otherwise a score that
-- rewards consecutive hits and matches near the start
local function score(needle, haystack)
	if needle == "" then
		return 0
	end

	local n, h = needle:lower(), haystack:lower()
	local total, from, last = 0, 1, nil

	for i = 1, #n do
		local at = h:find(n:sub(i, i), from, true)

		if not at then
			return nil
		end

		if last and at == last + 1 then
			total = total + 12
		end

		if at == 1 then
			total = total + 8
		end

		total = total - (at - from)
		last, from = at, at + 1
	end

	return total
end

function M.picker(opts)
	opts = opts or {}

	if active then
		return false
	end

	local s = resolveStyle(opts)
	local choices = opts.choices or {}
	local maxRows = opts.rows or 8
	local width = opts.width or 620
	local pad = 16
	local titleSize = math.max(14, s.size - 4)
	local titleHeight = titleSize + 6
	local queryHeight = s.size * 1.35
	local subSize = math.max(11, s.size - 6)
	local nameHeight = s.size * 1.3
	local subHeight = subSize * 1.35
	local rowPad = 5
	local rowHeight = rowPad * 2 + nameHeight + subHeight
	local iconSize = math.min(38, rowHeight - rowPad * 2)
	local iconGap = 10
	local gap = 10
	local hasImages = false

	for _, choice in ipairs(choices) do
		if choice.image or choice.imageProvider then
			hasImages = true
			break
		end
	end

	local query = ""
	local matches = {}
	local selected = 1
	local offset = 0

	local canvas = newCanvas(width, pad + titleHeight + queryHeight + gap + rowHeight + pad, opts.y)

	local function shown()
		return math.min(#matches, maxRows)
	end

	local function clampSelection()
		if #matches == 0 then
			selected, offset = 1, 0
			return
		end

		selected = math.max(1, math.min(selected, #matches))

		if selected <= offset then
			offset = selected - 1
		elseif selected > offset + maxRows then
			offset = selected - maxRows
		end

		offset = math.max(0, math.min(offset, math.max(0, #matches - maxRows)))
	end

	local render

	local function choiceImage(choice)
		if choice.imageResolved or choice.imageLoading or not choice.imageProvider then
			return choice.image
		end

		choice.imageLoading = true
		local image = choice.imageProvider(function(resolved)
			choice.image = resolved
			choice.imageLoading = false
			choice.imageResolved = true

			hs.timer.doAfter(0, function()
				if active and active.canvas == canvas then
					render()
				end
			end)
		end)

		if image then
			choice.image = image
			choice.imageLoading = false
			choice.imageResolved = true
		end

		return choice.image
	end

	render = function()
		local rows = math.max(shown(), 1)
		local height = pad + titleHeight + queryHeight + gap + rows * rowHeight + pad

		-- the top edge stays put and the box grows downwards, so the list
		-- does not jump around as the query narrows it
		canvas:frame(geometry(width, height, opts.y))

		local elements = chrome(width, height, s)

		table.insert(elements, {
			type = "text",
			text = opts.prompt or "",
			textColor = fade(s.color, 0.7),
			textSize = titleSize,
			textFont = s.font,
			textAlignment = "center",
			frame = { x = pad, y = pad, w = width - pad * 2, h = titleHeight },
		})

		table.insert(elements, {
			type = "text",
			text = query .. "|",
			textColor = s.color,
			textSize = s.size,
			textFont = s.font,
			textAlignment = "center",
			textLineBreak = "truncateHead",
			frame = { x = pad, y = pad + titleHeight, w = width - pad * 2, h = queryHeight },
		})

		local top = pad + titleHeight + queryHeight + gap

		if #matches == 0 then
			table.insert(elements, {
				type = "text",
				text = opts.emptyText or "no matches",
				textColor = fade(s.color, 0.4),
				textSize = s.size,
				textFont = s.font,
				textAlignment = "center",
				frame = { x = pad, y = top + rowPad, w = width - pad * 2, h = nameHeight },
			})
		end

		for i = 1, shown() do
			local index = i + offset
			local choice = matches[index]
			local y = top + (i - 1) * rowHeight
			local isSelected = index == selected
			local textX = pad + 6

			if isSelected then
				table.insert(elements, {
					type = "rectangle",
					action = "fill",
					fillColor = fade(s.stroke, 0.14),
					roundedRectRadii = { xRadius = 12, yRadius = 12 },
					frame = { x = pad - 6, y = y, w = width - (pad - 6) * 2, h = rowHeight },
				})
			end

			if hasImages then
				local image = choiceImage(choice)

				if image then
					table.insert(elements, {
						type = "image",
						image = image,
						imageScaling = "scaleProportionally",
						frame = {
							x = textX,
							y = y + (rowHeight - iconSize) / 2,
							w = iconSize,
							h = iconSize,
						},
					})
				end

				textX = textX + iconSize + iconGap
			end

			local textWidth = width - textX - pad - 6

			table.insert(elements, {
				type = "text",
				text = choice.text,
				textColor = isSelected and s.color or fade(s.color, 0.72),
				textSize = s.size,
				textFont = s.font,
				textLineBreak = "truncateTail",
				frame = { x = textX, y = y + rowPad, w = textWidth, h = nameHeight },
			})

			if choice.subText and choice.subText ~= "" then
				table.insert(elements, {
					type = "text",
					text = choice.subText,
					textColor = fade(s.color, isSelected and 0.6 or 0.4),
					textSize = subSize,
					textFont = s.font,
					textLineBreak = "truncateTail",
					frame = { x = textX, y = y + rowPad + nameHeight, w = textWidth, h = subHeight },
				})
			end
		end

		canvas:replaceElements(table.unpack(elements))
	end

	local function refresh()
		local ranked = {}

		for _, choice in ipairs(choices) do
			local onName = score(query, choice.text)
			local onAll = score(query, choice.text .. " " .. (choice.subText or ""))
			-- a hit on the name itself outranks one that needed the subtext
			local best = onName and onName + 20 or onAll

			if best then
				-- choice.boost lets the caller break ties between equally good
				-- textual matches; with no query it is the whole ordering
				table.insert(ranked, { choice = choice, score = best + (choice.boost or 0) })
			end
		end

		table.sort(ranked, function(a, b)
			if a.score ~= b.score then
				return a.score > b.score
			end

			-- equal score means the query matched both the same way, so prefer
			-- the shorter name: it is the one the query covers more of
			if #a.choice.text ~= #b.choice.text then
				return #a.choice.text < #b.choice.text
			end

			return a.choice.text:lower() < b.choice.text:lower()
		end)

		matches = {}

		for _, entry in ipairs(ranked) do
			table.insert(matches, entry.choice)
		end

		selected, offset = 1, 0
		clampSelection()
		render()
	end

	refresh()
	local focus = modalFocus.take()
	canvas:show()

	active = { canvas = canvas, focus = focus }

	active.tap = startTap(function(event)
		local keyCode = event:getKeyCode()
		local flags = event:getFlags()
		local map = hs.keycodes.map

		if keyCode == map["escape"] then
			local cancel = opts.onCancel
			close()

			if cancel then
				cancel()
			end

			return
		end

		-- shift+return is a variant of what return does to the highlighted row,
		-- for the cases the binder cannot express: which row it applies to is
		-- only known once something is selected. tab is deliberately left free
		-- for switching what the picker is listing.
		if keyCode == map["return"] and flags.shift and opts.onAlternate then
			local choice = matches[selected]

			if not choice then
				return
			end

			local alternate = opts.onAlternate
			close()
			alternate(choice)

			return
		end

		if keyCode == map["return"] then
			local choice = matches[selected]

			if not choice then
				return
			end

			local select = opts.onSelect
			close()

			if select then
				select(choice)
			end

			return
		end

		if keyCode == map["down"] or (flags.ctrl and keyCode == map["n"]) then
			selected = selected + 1
			clampSelection()
			render()
			return
		end

		if keyCode == map["up"] or (flags.ctrl and keyCode == map["p"]) then
			selected = selected - 1
			clampSelection()
			render()
			return
		end

		local updated, changed = editBuffer(query, event)

		if changed then
			query = updated
			refresh()
		end
	end)

	return true
end

-- the helper is not modal: RecursiveBinder owns the keyboard and the focus
-- while it is up, so it keeps its own slot rather than sharing `active`
local helperCanvas = nil

function M.hideHelper()
	if helperCanvas then
		helperCanvas:delete()
		helperCanvas = nil
	end
end

-- entries maps a key name to { name = ..., layer = ... }, as the patched
-- RecursiveBinder builds it
function M.helper(entries, opts)
	opts = opts or {}
	M.hideHelper()

	local s = resolveStyle(opts)
	local rows = {}

	for key, entry in pairs(entries) do
		table.insert(rows, { key = key, name = entry.name, layer = entry.layer })
	end

	if #rows == 0 then
		return
	end

	-- layers first, then leaf actions: where I go above what I do. Alphabetical
	-- by key inside each block, so a row holds its position across reloads
	table.sort(rows, function(a, b)
		if a.layer ~= b.layer then
			return a.layer
		end

		return a.key < b.key
	end)

	local pad = opts.padding or 22
	local gap = 10
	local arrow = "→"
	local lineHeight = s.size * 1.35
	local keyWidth, nameWidth = 0, 0

	for _, row in ipairs(rows) do
		keyWidth = math.max(keyWidth, textWidth(row.key, s.font, s.size))
		nameWidth = math.max(nameWidth, textWidth(row.name, s.font, s.size))
	end

	-- canvas clips a text element to its frame, and the measured width can land
	-- a fraction under what it draws, so every column carries a point of slack
	keyWidth, nameWidth = keyWidth + 1, nameWidth + 1

	local arrowWidth = textWidth(arrow, s.font, s.size) + 1
	local width = pad * 2 + keyWidth + gap + arrowWidth + gap + nameWidth
	local nameX = pad + keyWidth + gap + arrowWidth + gap

	-- the first leaf action, and so where the rule goes; nil when the layer
	-- holds only one of the two kinds and there is nothing to separate
	local ruleAt = nil

	for i, row in ipairs(rows) do
		if not row.layer then
			ruleAt = i > 1 and i or nil
			break
		end
	end

	local ruleGap = ruleAt and 13 or 0
	local height = pad * 2 + #rows * lineHeight + ruleGap
	local screen = hs.screen.mainScreen():fullFrame()

	helperCanvas = newCanvas(width, height, screen.y + (screen.h - height) / 2)

	local elements = chrome(width, height, s)

	if ruleAt then
		table.insert(elements, {
			type = "rectangle",
			action = "fill",
			fillColor = fade(s.stroke, 0.25),
			frame = {
				x = pad,
				y = pad + (ruleAt - 1) * lineHeight + ruleGap / 2,
				w = width - pad * 2,
				h = 1,
			},
		})
	end

	for i, row in ipairs(rows) do
		local y = pad + (i - 1) * lineHeight + (ruleAt and i >= ruleAt and ruleGap or 0)

		-- the key is the only thing to read, so it alone is at full white; the
		-- arrow is punctuation, and a leaf action needs less weight than the
		-- layer it sits under
		local columns = {
			{ text = row.key, x = pad, w = keyWidth, color = s.color },
			{ text = arrow, x = pad + keyWidth + gap, w = arrowWidth, color = fade(s.color, 0.3) },
			{ text = row.name, x = nameX, w = nameWidth, color = row.layer and s.color or fade(s.color, 0.7) },
		}

		for _, column in ipairs(columns) do
			table.insert(elements, {
				type = "text",
				text = column.text,
				textColor = column.color,
				textSize = s.size,
				textFont = s.font,
				frame = { x = column.x, y = y, w = column.w, h = lineHeight },
			})
		end
	end

	helperCanvas:replaceElements(table.unpack(elements))
	helperCanvas:show()
end

return M
